//
//  PaymentProviderTests.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/06.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase
import InAppPurchaseStubs

class PaymentProviderTests: XCTestCase {

    func testCanMakePayments() {
        let queue1 = StubPaymentQueue(canMakePayments: true)
        let provider1 = PaymentProvider(paymentQueue: queue1)
        XCTAssertTrue(provider1.canMakePayments())

        let queue2 = StubPaymentQueue(canMakePayments: false)
        let provider2 = PaymentProvider(paymentQueue: queue2)
        XCTAssertFalse(provider2.canMakePayments())
    }

    func testAddTransactionObserver() {
        let expectation = self.expectation()
        let queue = StubPaymentQueue(addObserverHandler: { (observer) in
            XCTAssertTrue(observer is PaymentProvider)
            expectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)
        provider.addTransactionObserver()
        self.wait(for: [expectation], timeout: 1)
    }

    func testRemoveTransactionObserver() {
        let expectation = self.expectation()
        let queue = StubPaymentQueue(removeObserverHandler: { (observer) in
            XCTAssertTrue(observer is PaymentProvider)
            expectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)
        provider.removeTransactionObserver()
        self.wait(for: [expectation], timeout: 1)
    }

    func testAddPayment() {
        let expectation = self.expectation()
        let queue = StubPaymentQueue(addPaymentHandler: { _ in
            expectation.fulfill()
        })

        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let provider = PaymentProvider(paymentQueue: queue)
        provider.add(payment: payment) { _, _ in }
        self.wait(for: [expectation], timeout: 1)
    }

    func testAddPaymentWithProductIdentifier() {
        let expectation = self.expectation()
        let queue = StubPaymentQueue()

        let provider = PaymentProvider(paymentQueue: queue)
        provider.addPaymentHandler(withProductIdentifier: "PAYMENT_001", handler: { _, _ in
            expectation.fulfill()
        })

        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: nil,
            payment: payment
        )
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        self.wait(for: [expectation], timeout: 1)
    }

    func testPurchase() {
        let finishExpectation = self.expectation()
        let queue = StubPaymentQueue(finishTransactionHandler: { _ in
            finishExpectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)
        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let expectation = self.expectation()

        provider.add(payment: payment) { _, result in
            switch result {
            case .success(let transaction):
                XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }

        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: nil,
            payment: payment
        )
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        self.wait(for: [finishExpectation, expectation], timeout: 1)
    }

    func testRestoreCompletedTransactions() {
        let expectation = self.expectation()
        let queue = StubPaymentQueue(restoreCompletedTransactionsHandler: {
            expectation.fulfill()
        })

        let provider = PaymentProvider(paymentQueue: queue)
        provider.restoreCompletedTransactions(handler: { _, _ -> Void in })
        self.wait(for: [expectation], timeout: 1)
    }

    func testRestore() {
        let restoreExpectation = self.expectation()
        let finishExepextation = self.expectation()
        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: nil,
            payment: payment
        )
        let queue = StubPaymentQueue(
            transactions: [transaction],
            restoreCompletedTransactionsHandler: {
                restoreExpectation.fulfill()
        },
            finishTransactionHandler: { _ in
                finishExepextation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)
        let expectation = self.expectation()
        provider.restoreCompletedTransactions { queue, error in
            XCTAssertNil(error)
            XCTAssertEqual(queue.transactions.map({ $0.transactionIdentifier }), ["TRANSACTION_001"])
            XCTAssertEqual(queue.transactions.map({ $0.payment.productIdentifier }), ["PAYMENT_001"])
            expectation.fulfill()
        }
        // Maybe updateTransactions is called and then restore completed method is called.
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        provider.paymentQueueRestoreCompletedTransactionsFinished(queue)
        self.wait(for: [restoreExpectation, finishExepextation, expectation], timeout: 1)
    }

    /// Condition: the methods of SKPaymentTransactionObserver is called multiple times for one Restore method call.
    /// Expect: RestoreHandler will be executed once.
    func testRestoreWhereObserverMultiCalled() {
        let finishExpectation = self.expectation()
        finishExpectation.expectedFulfillmentCount = 2
        let queue = StubPaymentQueue(finishTransactionHandler: { _ in
            // Should be called 2 times
            finishExpectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)

        let expectation = self.expectation()
        provider.restoreCompletedTransactions { _, error in
            XCTAssertNil(error)
            // Should be called once
            expectation.fulfill()
        }

        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: nil,
            payment: payment
        )
        // Call multiple times
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        provider.paymentQueueRestoreCompletedTransactionsFinished(queue)
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        provider.paymentQueueRestoreCompletedTransactionsFinished(queue)
        self.wait(for: [finishExpectation, expectation], timeout: 1)
    }

    /// Condition: Restore method is called multiple times before store restoration is completed.
    /// Expect: All RestoreHandler will be executed.
    func testRestoreMultiCalled() {
        let finishExpectation = self.expectation()
        let queue = StubPaymentQueue(finishTransactionHandler: { _ in
            finishExpectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)

        // First restore
        let expectation1 = self.expectation()
        provider.restoreCompletedTransactions { _, error in
            XCTAssertNil(error)
            expectation1.fulfill()
        }

        // Second restore
        let expectation2 = self.expectation()
        provider.restoreCompletedTransactions { _, error in
            XCTAssertNil(error)
            expectation2.fulfill()
        }

        // Execute all registered Restore Handlers
        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: nil,
            payment: payment
        )
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        provider.paymentQueueRestoreCompletedTransactionsFinished(queue)
        self.wait(for: [finishExpectation, expectation1, expectation2], timeout: 1)
    }

    func testRestoreWhereFailure() {
        let finishExpectation = self.expectation()
        let queue = StubPaymentQueue(finishTransactionHandler: { _ in
            finishExpectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)

        let expectation = self.expectation()
        provider.restoreCompletedTransactions { _, error in
            if let error = error, case let .with(err) = error {
                let err = err as NSError
                XCTAssertEqual(err.domain, "test")
                XCTAssertEqual(err.code, 500)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        let error = NSError(domain: "test", code: 500, userInfo: nil)
        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .failed,
            original: nil,
            payment: payment
        )
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        provider.paymentQueue(queue, restoreCompletedTransactionsFailedWithError: error)
        wait(for: [finishExpectation, expectation], timeout: 1)
    }

    func testSetFallbackHandler() {
        let finishExpectation = self.expectation()
        let queue = StubPaymentQueue(finishTransactionHandler: { _ in
            finishExpectation.fulfill()
        })
        let provider = PaymentProvider(paymentQueue: queue)
        let expectation = self.expectation()
        provider.set(fallbackHandler: { (_, result) in
            switch result {
            case .success(let transaction):
                XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        })
        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: nil,
            payment: payment
        )
        provider.paymentQueue(queue, updatedTransactions: [transaction])
        self.wait(for: [expectation, finishExpectation], timeout: 1)
    }

    func testSetShouldAddStorePaymentHandler() {
        let queue = StubPaymentQueue()
        let provider = PaymentProvider(paymentQueue: queue)
        let expectation = self.expectation()
        provider.set(shouldAddStorePaymentHandler: { (_, _, _) -> Bool in
            expectation.fulfill()
            return true
        })

        let payment = StubPayment(productIdentifier: "PAYMENT_001")
        let product = StubProduct(productIdentifier: "PAYMENT_001")
        XCTAssertTrue(provider.paymentQueue(queue, shouldAddStorePayment: payment, for: product))
        self.wait(for: [expectation], timeout: 1)
    }
}
