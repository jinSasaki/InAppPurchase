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

class PaymentTransactionTests: XCTestCase {
    func testInit() {
        let original = StubPaymentTransaction(
            transactionIdentifier: "ORIGINAL_TRANSACTION_001",
            transactionState: .purchased
        )

        let payment = StubPayment(productIdentifier: "PRODUCT_001")

        let skTransaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: original,
            payment: payment)

        let transaction = Internal.PaymentTransaction(skTransaction)

        XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
        XCTAssertEqual(transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
        XCTAssertEqual(transaction.productIdentifier, "PRODUCT_001")
    }
}
