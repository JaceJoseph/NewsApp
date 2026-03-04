//
//  SourcesViewModelTest.swift
//  NewsAppTests
//
//  Created by Jesse on 04/03/26.
//

import XCTest
@testable import NewsApp

final class MockSourcesDelegate: NewsSourcesViewModelDelegate {
    var didStartLoadingCalled = false
    var didFinishLoadingCalled = false
    var didUpdateSourcesCalled = false
    var receivedErrorMessage: String?

    func didStartLoading() {
        didStartLoadingCalled = true
    }

    func didFinishLoading() {
        didFinishLoadingCalled = true
    }

    func didUpdateSources() {
        didUpdateSourcesCalled = true
    }

    func didReceiveError(_ message: String) {
        receivedErrorMessage = message
    }
}

@MainActor
final class SourcesViewModelTest: XCTestCase {
    func testFetchSourcesSuccess() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockSourcesDelegate()

        let expectedSources = [
            NewsSource(id: "1", name: "BBC", description: "", url: "", category: "", language: "", country: "")
        ]

        let response = NewsSourcesResponse(status: "ok", sources: expectedSources)

        mockNetwork.result = .success(response)

        let viewModel = SourcesViewModel(networkService: mockNetwork)
        viewModel.delegate = mockDelegate

        await viewModel.fetchSources()

        XCTAssertTrue(mockDelegate.didStartLoadingCalled)
        XCTAssertTrue(mockDelegate.didFinishLoadingCalled)
        XCTAssertTrue(mockDelegate.didUpdateSourcesCalled)
        XCTAssertEqual(viewModel.filteredSources.count, 1)
    }
    
    func testFetchSourcesNoInternet() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockSourcesDelegate()

        mockNetwork.result = .failure(NetworkError.noInternet)

        let viewModel = SourcesViewModel(networkService: mockNetwork)
        viewModel.delegate = mockDelegate

        await viewModel.fetchSources()

        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, no internet access detected"
        )
    }
    
    func testFetchSourcesRTO() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockSourcesDelegate()

        mockNetwork.result = .failure(NetworkError.timeout)

        let viewModel = SourcesViewModel(networkService: mockNetwork)
        viewModel.delegate = mockDelegate

        await viewModel.fetchSources()

        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, getting the sources took way too long"
        )
    }
    
    func testFetchSourcesInvalidResponse() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockSourcesDelegate()
        let errorCode = 400
        
        mockNetwork.result = .failure(NetworkError.invalidResponse(code: errorCode))

        let viewModel = SourcesViewModel(networkService: mockNetwork)
        viewModel.delegate = mockDelegate

        await viewModel.fetchSources()

        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Error \(errorCode): Sorry, failed to load the sources"
        )
    }
    
    func testFetchSourcesInvaliDecoding() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockSourcesDelegate()
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: "Mock corrupted JSON"
        )

        let decodingError = DecodingError.dataCorrupted(context)
        
        mockNetwork.result = .failure(NetworkError.decodingError(error: decodingError))

        let viewModel = SourcesViewModel(networkService: mockNetwork)
        viewModel.delegate = mockDelegate

        await viewModel.fetchSources()

        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "\(decodingError.localizedDescription): Sorry, failed to load sources"
        )
    }
    
    func testFetchSourcesInvalid() async {
        let mockNetwork = MockNetworkService()
        let mockDelegate = MockSourcesDelegate()
        
        mockNetwork.result = .failure(NetworkError.invalidURL)

        let viewModel = SourcesViewModel(networkService: mockNetwork)
        viewModel.delegate = mockDelegate

        await viewModel.fetchSources()

        XCTAssertEqual(
            mockDelegate.receivedErrorMessage,
            "Sorry, failed to load sources."
        )
    }
    
    func testSearchSourcesFiltersCorrectly() async {
        let mockNetwork = MockNetworkService()
        let sources = [
            NewsSource(id: "1", name: "BBC News", description: "", url: "", category: "", language: "", country: ""),
            NewsSource(id: "2", name: "CNN", description: "", url: "", category: "", language: "", country: "")
        ]
        let response = NewsSourcesResponse(status: "ok", sources: sources)
        mockNetwork.result = .success(response)
        
        let viewModel = SourcesViewModel(networkService: mockNetwork)
        await viewModel.fetchSources()
        viewModel.searchSources(with: nil) // ensure clean state
        XCTAssertEqual(viewModel.filteredSources.count, 2)
        viewModel.searchSources(with: "bbc")
        XCTAssertEqual(viewModel.filteredSources.count, 1)
        XCTAssertEqual(viewModel.filteredSources.first?.name, "BBC News")
    }
}
