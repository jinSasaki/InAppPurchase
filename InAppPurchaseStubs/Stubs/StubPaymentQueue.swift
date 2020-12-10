//
//  StubPaymentQueue.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import InAppPurchase
import StoreKit

public final class StubPaymentQueue: SKPaymentQueue {
    private static var _canMakePayments: Bool = false
    private let _transactions: [StubPaymentTransaction]
    private let _addObserverHandler: ((_ observer: SKPaymentTransactionObserver) -> Void)?
    private let _removeObserverHandler: ((_ observer: SKPaymentTransactionObserver) -> Void)?
    private let _addPaymentHandler: ((_ payment: SKPayment) -> Void)?
    private let _restoreCompletedTransactionsHandler: (() -> Void)?
    private let _finishTransactionHandler: ((_ transaction: SKPaymentTransaction) -> Void)?

    public init(canMakePayments: Bool = true,
                transactions: [StubPaymentTransaction] = [],
                addObserverHandler: ((_ observer: SKPaymentTransactionObserver) -> Void)? = nil,
                removeObserverHandler: ((_ observer: SKPaymentTransactionObserver) -> Void)? = nil,
                addPaymentHandler: ((_ payment: SKPayment) -> Void)? = nil,
                restoreCompletedTransactionsHandler: (() -> Void)? = nil,
                finishTransactionHandler: ((_ transaction: SKPaymentTransaction) -> Void)? = nil) {

        StubPaymentQueue._canMakePayments = canMakePayments
        self._transactions = transactions
        self._addObserverHandler = addObserverHandler
        self._removeObserverHandler = removeObserverHandler
        self._addPaymentHandler = addPaymentHandler
        self._restoreCompletedTransactionsHandler = restoreCompletedTransactionsHandler
        self._finishTransactionHandler = finishTransactionHandler
    }

    @objc public override class func canMakePayments() -> Bool {
        return _canMakePayments
    }

    public override func add(_ observer: SKPaymentTransactionObserver) {
        _addObserverHandler?(observer)
    }

    public override func remove(_ observer: SKPaymentTransactionObserver) {
        _removeObserverHandler?(observer)
    }

    public override func add(_ payment: SKPayment) {
        _addPaymentHandler?(payment)
    }

    public override func restoreCompletedTransactions() {
        _restoreCompletedTransactionsHandler?()
    }

    public override func finishTransaction(_ transaction: SKPaymentTransaction) {
        _finishTransactionHandler?(transaction)
    }

    public override var transactions: [SKPaymentTransaction] {
        return self._transactions
    }
}
