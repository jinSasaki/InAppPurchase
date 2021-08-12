//
//  PaymentTransactionTests.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase
import InAppPurchaseStubs
import StoreKit

class PaymentTransactionTests: XCTestCase {
    func testTransactionState() {
        XCTAssertEqual(PaymentTransaction.State.purchasing, PaymentTransaction.State(.purchasing))
        XCTAssertEqual(PaymentTransaction.State.purchased, PaymentTransaction.State(.purchased))
        XCTAssertEqual(PaymentTransaction.State.failed, PaymentTransaction.State(.failed))
        XCTAssertEqual(PaymentTransaction.State.restored, PaymentTransaction.State(.restored))
        XCTAssertEqual(PaymentTransaction.State.deferred, PaymentTransaction.State(.deferred))
        XCTAssertEqual(PaymentTransaction.State.unknown(rawValue: 10), PaymentTransaction.State(SKPaymentTransactionState(rawValue: 10) ?? .deferred))
    }

    func testInit() {
        let original = StubPaymentTransaction(
            transactionIdentifier: "ORIGINAL_TRANSACTION_001",
            transactionState: .purchased
        )

        let payment = StubPayment(productIdentifier: "PRODUCT_001")

        let skTransaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: original,
            payment: payment
        )

        let transaction = PaymentTransaction(skTransaction)

        XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
        XCTAssertEqual(transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
        XCTAssertEqual(transaction.productIdentifier, "PRODUCT_001")
        XCTAssertEqual(transaction.state, .restored)
        XCTAssertEqual(transaction.original?.transactionIdentifier, "ORIGINAL_TRANSACTION_001")
        XCTAssertEqual(transaction.original?.state, .purchased)
    }

    func testInitWithoutOriginal() {
        let payment = StubPayment(productIdentifier: "PRODUCT_001")

        let skTransaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: nil,
            payment: payment
        )

        let transaction = PaymentTransaction(skTransaction)
        XCTAssertNil(transaction.original)
    }
}
