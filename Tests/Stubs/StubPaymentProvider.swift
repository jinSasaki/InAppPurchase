//
//  StubPaymentProvider.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
@testable import InAppPurchase
import StoreKit

final class StubPaymentProvider: PaymentProvidable {
    private let _canMakePayments: Bool
    private let _addTransactionObserverHandler: (() -> Void)?
    private let _removeTransactionObserverHandler: (() -> Void)?
    private let _restoreHandler: ((_ handler: @escaping RestoreHandler) -> Void)?
    private let _addPaymentHandler: ((_ payment: SKPayment, _ handler: @escaping PaymentHandler) -> Void)?
    private let _addProductIdentifierHandler: ((_ productIdentifier: String, _ handler: @escaping PaymentHandler) -> Void)?
    private let _setShouldAddStorePaymentHandler: ((@escaping ShouldAddStorePaymentHandler) -> Void)?
    private let _finishDeferredTransactionHandler: ((_ finishDeferredTransactionHandler: @escaping DeferredHandler) -> Void)?

    init(canMakePayments: Bool = true,
         addTransactionObserverHandler: (() -> Void)? = nil,
         removeTransactionObserverHandler: (() -> Void)? = nil,
         restoreHandler: ((_ handler: @escaping RestoreHandler) -> Void)? = nil,
         addPaymentHandler: ((_ payment: SKPayment, _ handler: @escaping PaymentHandler) -> Void)? = nil,
         addProductIdentifierHandler: ((_ productIdentifier: String, _ handler: @escaping PaymentHandler) -> Void)? = nil,
         setShouldAddStorePaymentHandler: ((@escaping ShouldAddStorePaymentHandler) -> Void)? = nil,
         finishDeferredTransactionHandler: ((_ finishDeferredTransactionHandler: @escaping DeferredHandler) -> Void)? = nil) {

        self._canMakePayments = canMakePayments
        self._addTransactionObserverHandler = addTransactionObserverHandler
        self._removeTransactionObserverHandler = removeTransactionObserverHandler
        self._restoreHandler = restoreHandler
        self._addPaymentHandler = addPaymentHandler
        self._addProductIdentifierHandler = addProductIdentifierHandler
        self._setShouldAddStorePaymentHandler = setShouldAddStorePaymentHandler
        self._finishDeferredTransactionHandler = finishDeferredTransactionHandler
    }

    func canMakePayments() -> Bool {
        return _canMakePayments
    }

    func addTransactionObserver() {
        _addTransactionObserverHandler?()
    }

    func removeTransactionObserver() {
        _removeTransactionObserverHandler?()
    }

    func restoreCompletedTransactions(handler: @escaping RestoreHandler) {
        _restoreHandler?(handler)
    }

    func add(payment: SKPayment, handler: @escaping PaymentHandler) {
        _addPaymentHandler?(payment, handler)
    }

    func set(shouldAddStorePaymentHandler: @escaping ShouldAddStorePaymentHandler) {
        _setShouldAddStorePaymentHandler?(shouldAddStorePaymentHandler)
    }

    func addPaymentHandler(withProductIdentifier productIdentifier: String, handler: @escaping PaymentHandler) {
        _addProductIdentifierHandler?(productIdentifier, handler)
    }

    func add(finishDeferredTransactionHandler: @escaping DeferredHandler) {
        _finishDeferredTransactionHandler?(finishDeferredTransactionHandler)
    }
}
