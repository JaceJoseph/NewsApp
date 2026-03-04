//
//  ArticlesViewModelTest.swift
//  NewsAppTests
//
//  Created by Jesse on 04/03/26.
//

import XCTest
@testable import NewsApp

// mock delegate for test
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
        // setup mock network responses
        let articles = (1...10).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: "", content: "content")
        }
        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 10, articles: articles)
        )

        // setup vm to fetch
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        await vm.fetchArticles()
        // check if delegates are called
        XCTAssertTrue(mockDelegate.didStartLoadingCalled)
        XCTAssertTrue(mockDelegate.didUpdateArticlesCalled)
        XCTAssertTrue(mockDelegate.didFinishLoadingCalled)
        XCTAssertEqual(vm.articles.count, 10)
        
        // try fetching again, but should fail because less than pageSize 20, canLoadMore is false
        await vm.fetchArticles()
        XCTAssertEqual(vm.articles.count, 10)
    }
    
    func testFetchArticlesPaginationAppends() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        // setup mock network responses
        let articles = (1...20).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: "", content: "content")
        }
        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 40, articles: articles)
        )
        // setup vm to fetch
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        await vm.fetchArticles()
        await vm.fetchArticles()
        // check if the articles append instead of resetting, since it can load more
        XCTAssertEqual(vm.articles.count, 40)
    }
    
    func testFetchArticlesResetClearsPreviousData() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        // setup mock network responses
        let page1 = (1...20).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: "Date", content: "content")
        }
        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 20, articles: page1)
        )
        // setup vm to fetch
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        await vm.fetchArticles()
        XCTAssertEqual(vm.articles.count, 20)
        // vm fetch with reset true, should still be 20 because data is emptied then refetched
        await vm.fetchArticles(reset: true)
        XCTAssertEqual(vm.articles.count, 20)
    }

    func testFetchArticlesNoInternet() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        // setup mock network responses for error
        mockNetwork.result = .failure(NetworkError.noInternet)
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        // simulate delegate error
        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, no internet access detected"
        )
    }
    
    func testFetchArticlesTimedOut() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        // setup mock network responses for error
        mockNetwork.result = .failure(NetworkError.timeout)
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        // simulate delegate error
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
        // setup mock network responses for error
        mockNetwork.result = .failure(NetworkError.invalidResponse(code: errorCode))
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        // simulate delegate error
        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Error \(errorCode): Sorry, failed to load the articles"
        )
    }
    
    func testFetchArticlesInvalid() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        // setup mock network responses for error
        mockNetwork.result = .failure(NetworkError.invalidURL)
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        // simulate delegate error
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
        // setup mock network responses for error
        let decodingError = DecodingError.dataCorrupted(context)
        mockNetwork.result = .failure(NetworkError.decodingError(error: decodingError))
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        // simulate delegate error
        await vm.fetchArticles()
        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "\(decodingError.localizedDescription): Sorry, failed to load articles"
        )
    }
    
    func testSearchArticlesResetsAndFetches() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockArticlesDelegate()
        // setup mock network responses
        let page1 = (1...20).map {
            NewsArticle(source: ArticleSource(id: "\($0)", name: "Source \($0)"), author: "Author \($0)", title: "\($0)", description: "desc", url: "", urlToImage: "", publishedAt: "Date", content: "content")
        }
        mockNetwork.result = .success(
            NewsArticlesResponse(status: "ok", totalResults: 20, articles: page1)
        )
        // setup vm to fetch
        let vm = ArticlesViewModel(networkService: mockNetwork)
        vm.delegate = mockDelegate
        await vm.searchArticles(keyword: "bitcoin")
        XCTAssertTrue(mockDelegate.didStartLoadingCalled)
        XCTAssertTrue(mockDelegate.didUpdateArticlesCalled)
        XCTAssertTrue(mockDelegate.didFinishLoadingCalled)
        // Old article should be gone because search would reset the array
        XCTAssertEqual(vm.articles.count, 20)
    }
}
