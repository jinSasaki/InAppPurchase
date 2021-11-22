//
//  ProductProviderTests.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/06.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase
import StoreKit
import InAppPurchaseStubs

class ProductProviderTests: XCTestCase {

    let provider = ProductProvider()

    func testMakeRequest() {
        let request = provider.makeRequest(productIdentifiers: ["PRODUCT_001"], requestId: "REQUEST_001")
        XCTAssertTrue(request.delegate === provider)
        XCTAssertEqual(request.id, "REQUEST_001")
    }

    func testFetch() {
        let expectation = self.expectation()
        let request = StubProductsRequest(startHandler: {
            expectation.fulfill()
        })
        provider.fetch(request: request) { _ in }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithRequestWhereSuccess() {
        let request = provider.makeRequest(productIdentifiers: ["PRODUCT_001"], requestId: "REQUEST_001")
        let expectation = self.expectation()
        provider.fetch(request: request) { (result) in
            switch result {
            case .success(let products):
                XCTAssertEqual(products.count, 1)
                XCTAssertEqual(products.first?.productIdentifier, "PRODUCT_001")
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        let response = StubProductsResponse(products: [StubProduct(productIdentifier: "PRODUCT_001")], invalidProductIdentifiers: [])
        provider.productsRequest(request, didReceive: response)
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithRequestWhereInvalidIds() {
        let request = provider.makeRequest(productIdentifiers: ["INVALID_PRODUCT_001"], requestId: "REQUEST_001")
        let expectation = self.expectation()
        provider.fetch(request: request) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error.code {
                case .invalid(let productIds):
                    XCTAssertEqual(productIds.count, 1)
                    XCTAssertEqual(productIds.first, "INVALID_PRODUCT_001")
                default:
                    XCTFail()
                }
            }
            expectation.fulfill()
        }
        let response = StubProductsResponse(products: [StubProduct(productIdentifier: "PRODUCT_001")], invalidProductIdentifiers: ["INVALID_PRODUCT_001"])
        provider.productsRequest(request, didReceive: response)
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithRequestWhereRequestFailure() {
        let request = provider.makeRequest(productIdentifiers: ["INVALID_PRODUCT_001"], requestId: "REQUEST_001")
        let expectation = self.expectation()
        provider.fetch(request: request) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if case let .with(err) = error.code {
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

    // MARK: - SKRequest extension

    func testRequestId() {
        let request = SKRequest()
        XCTAssertEqual(request.id, "")

        request.id = "REQUEST_001"
        XCTAssertEqual(request.id, "REQUEST_001")

        request.id = "REQUEST_002"
        XCTAssertEqual(request.id, "REQUEST_002")
    }
}
