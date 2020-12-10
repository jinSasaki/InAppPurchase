//
//  StubPaymentTransaction.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public final class StubPaymentTransaction: SKPaymentTransaction {
    private let _transactionIdentifier: String?
    private let _transactionState: SKPaymentTransactionState
    private let _original: StubPaymentTransaction?
    private let _payment: SKPayment
    private let _error: Error?

    public init(transactionIdentifier: String? = nil,
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

    public override var transactionIdentifier: String? {
        return _transactionIdentifier
    }

    public override var transactionState: SKPaymentTransactionState {
        return _transactionState
    }

    public override var original: SKPaymentTransaction? {
        return _original
    }

    public override var payment: SKPayment {
        return _payment
    }

    public override var error: Error? {
        return _error
    }
}
