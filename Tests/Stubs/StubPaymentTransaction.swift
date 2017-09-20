//
//  StubPaymentTransaction.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final class StubPaymentTransaction: SKPaymentTransaction {
    private let _transactionIdentifier: String?
    private let _transactionState: SKPaymentTransactionState
    private let _original: StubPaymentTransaction?
    private let _payment: SKPayment
    private let _error: Error?

    init(transactionIdentifier: String? = nil,
         transactionState: SKPaymentTransactionState = .purchasing,
         original: StubPaymentTransaction? = nil,
         payment: SKPayment = StubPayment(productIdentifier: ""),
         error: Error? = nil) {

        self._transactionIdentifier = transactionIdentifier
        self._transactionState = transactionState
        self._original = original
        self._payment = payment
        self._error = error
    }

    override var transactionIdentifier: String? {
        return _transactionIdentifier
    }

    override var transactionState: SKPaymentTransactionState {
        return _transactionState
    }

    override var original: SKPaymentTransaction? {
        return _original
    }

    override var payment: SKPayment {
        return _payment
    }

    override var error: Error? {
        return _error
    }
}
