//
//  ReceiptRefreshProviderTests.swift
//  InAppPurchaseTests
//
//  Created by Jin Sasaki on 2020/12/10.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase
import StoreKit

final class ReceiptRefreshProviderTests: XCTestCase {

    let provider = ReceiptRefreshProvider()

    func testMakeRequest() {
        let request = provider.makeRequest(requestId: "REQUEST_001")
        XCTAssertTrue(request.delegate === provider)
        XCTAssertEqual(request.id, "REQUEST_001")
    }

    func testFetch() {
        let expectation = self.expectation()
        let request = StubReceiptRefreshRequest(startHandler: {
            expectation.fulfill()
        })
        provider.fetch(request: request) { _ in }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithRequestWhereSuccess() {
        let request = provider.makeRequest(requestId: "REQUEST_001")
        let expectation = self.expectation()
        provider.fetch(request: request) { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        provider.requestDidFinish(request)
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithRequestWhereRequestFailure() {
        let request = provider.makeRequest(requestId: "REQUEST_001")
        let expectation = self.expectation()
        provider.fetch(request: request) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if case let .with(err) = error {
                    let err = err as NSError
                    XCTAssertEqual(err.domain, "test")
                    XCTAssertEqual(err.code, 500)
                } else {
                    XCTFail()
                }
            }
            expectation.fulfill()
        }
        let error = NSError(domain: "test", code: 500, userInfo: nil)
        provider.request(request, didFailWithError: error)
        wait(for: [expectation], timeout: 1)
    }
}
