//
//  ArticlesViewModelTest.swift
//  NewsAppTests
//
//  Created by Jesse on 04/03/26.
//

import XCTest
@testable import NewsApp

final class MockArticlesDelegate: ArticlesViewModelDelegate {

    var didStartLoadingCalled = false
    var didFinishLoadingCalled = false
    var didUpdateArticlesCalled = false
    var receivedErrorMessage: String?

    func didStartLoading() {
        didStartLoadingCalled = true
    }

    func didFinishLoading() {
        didFinishLoadingCalled = true
    }

    func didUpdateArticles() {
        didUpdateArticlesCalled = true
    }

    func didReceiveError(_ message: String) {
        receivedErrorMessage = message
    }
}

@MainActor
final class ArticlesViewModelTest: XCTestCase {
    func testFetchArticlesSuccessFirstPage() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        let articles = (1...10).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: Date(), content: "content")
        }

        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 10, articles: articles)
        )

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()

        XCTAssertTrue(mockDelegate.didStartLoadingCalled)
        XCTAssertTrue(mockDelegate.didUpdateArticlesCalled)
        XCTAssertTrue(mockDelegate.didFinishLoadingCalled)

        XCTAssertEqual(vm.articles.count, 10)
        // try fetching again, but should fail because less than pageSize 20
        await vm.fetchArticles()
        XCTAssertEqual(vm.articles.count, 10)
    }
    
    func testFetchArticlesPaginationAppends() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        let articles = (1...20).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: Date(), content: "content")
        }
        
        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 40, articles: articles)
        )
        
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        await vm.fetchArticles()

        XCTAssertEqual(vm.articles.count, 40)
    }
    
    func testFetchArticlesResetClearsPreviousData() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        let page1 = (1...20).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: Date(), content: "content")
        }
        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 20, articles: page1)
        )

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        XCTAssertEqual(vm.articles.count, 20)

        await vm.fetchArticles(reset: true)
        XCTAssertEqual(vm.articles.count, 20) // replaced, not 40
    }

    func testFetchArticlesNoInternet() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        mockNetwork.result = .failure(NetworkError.noInternet)

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, no internet access detected"
        )
    }
    
    func testFetchArticlesTimedOut() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        mockNetwork.result = .failure(NetworkError.timeout)

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, getting the articles took way too long"
        )
    }
    
    func testFetchArticlesInvalidResponse() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        let errorCode = 400

        mockNetwork.result = .failure(NetworkError.invalidResponse(code: errorCode))

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Error \(errorCode): Sorry, failed to load the articles"
        )
    }
    
    func testFetchArticlesInvalid() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        mockNetwork.result = .failure(NetworkError.invalidURL)

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, failed to load sources."
        )
    }
    
    func testFetchArticlesDecodingError() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: "Mock corrupted JSON"
        )

        let decodingError = DecodingError.dataCorrupted(context)
        mockNetwork.result = .failure(NetworkError.decodingError(error: decodingError))

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate

        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "\(decodingError.localizedDescription): Sorry, failed to load articles"
        )
    }
    
    func testSearchArticlesResetsAndFetches() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()

        let page1 = (1...20).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: Date(), content: "content")
        }

        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 20, articles: page1)
        )

        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        await vm.searchArticles(keyword: "bitcoin")

        XCTAssertTrue(mockDelegate.didStartLoadingCalled)
        XCTAssertTrue(mockDelegate.didUpdateArticlesCalled)
        XCTAssertTrue(mockDelegate.didFinishLoadingCalled)

        // Old article should be gone
        XCTAssertEqual(vm.articles.count, 20)
    }
}
