//
//  InAppPurchaseIntegrationTests.swift
//  InAppPurchaseTests
//
//  Created by Jin Sasaki on 2017/12/20.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase

final class InAppPurchaseIntegrationTests: XCTestCase {

    /// ## Condition
    /// At first, purchase transaction is `.deferred`.
    /// After a few moment, InAppPurchase receives `.purchased`.
    ///
    /// ## Expectation
    /// InAppPurchase will call the registered fallback handler.
    func testBehaviorWhenDeferredAndThenPurchased() {
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let productProvider = StubProductProvider(result: .success([product]))
        let queue = StubPaymentQueue()
        let paymentProvider = PaymentProvider(paymentQueue: queue)

        let expectation1 = self.expectation()
        let expectation2 = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.addTransactionObserver(fallbackHandler: { (result) in
            switch result {
            case .success(let state):
                switch state {
                case .purchased:
                    break
                default:
                    XCTFail()
                }
            case .failure:
                XCTFail()
            }
            expectation1.fulfill()
        })
        iap.purchase(productIdentifier: "PRODUCT_001") { (result) in
            switch result {
            case .success(let state):
                XCTAssertEqual(state, .deferred)
            case .failure:
                XCTFail()
            }
            expectation2.fulfill()
        }

        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction1 = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .deferred,
            original: nil,
            payment: payment,
            error: nil
        )
        let transaction2 = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: nil,
            payment: payment,
            error: nil
        )
        paymentProvider.paymentQueue(queue, updatedTransactions: [transaction1])
        paymentProvider.paymentQueue(queue, updatedTransactions: [transaction2])
        self.wait(for: [expectation1, expectation2], timeout: 1)
    }
}
