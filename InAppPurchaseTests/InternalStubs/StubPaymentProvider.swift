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

public final class StubPaymentProvider: PaymentProvidable {
    private let _canMakePayments: Bool
    private let _addTransactionObserverHandler: (() -> Void)?
    private let _removeTransactionObserverHandler: (() -> Void)?
    private let _restoreHandler: ((_ handler: @escaping RestoreHandler) -> Void)?
    private let _addPaymentHandler: ((_ payment: SKPayment, _ handler: @escaping PaymentHandler) -> Void)?
    private let _addProductIdentifierHandler: ((_ productIdentifier: String, _ handler: @escaping PaymentHandler) -> Void)?
    private let _setShouldAddStorePaymentHandler: ((@escaping ShouldAddStorePaymentHandler) -> Void)?
    private let _fallbackHandler: ((_ fallbackHandler: @escaping PaymentHandler) -> Void)?

    public init(canMakePayments: Bool = true,
         addTransactionObserverHandler: (() -> Void)? = nil,
         removeTransactionObserverHandler: (() -> Void)? = nil,
         restoreHandler: ((_ handler: @escaping RestoreHandler) -> Void)? = nil,
         addPaymentHandler: ((_ payment: SKPayment, _ handler: @escaping PaymentHandler) -> Void)? = nil,
         addProductIdentifierHandler: ((_ productIdentifier: String, _ handler: @escaping PaymentHandler) -> Void)? = nil,
         setShouldAddStorePaymentHandler: ((@escaping ShouldAddStorePaymentHandler) -> Void)? = nil,
         fallbackHandler: ((_ fallbackHandler: @escaping PaymentHandler) -> Void)? = nil) {

        self._canMakePayments = canMakePayments
        self._addTransactionObserverHandler = addTransactionObserverHandler
        self._removeTransactionObserverHandler = removeTransactionObserverHandler
        self._restoreHandler = restoreHandler
        self._addPaymentHandler = addPaymentHandler
        self._addProductIdentifierHandler = addProductIdentifierHandler
        self._setShouldAddStorePaymentHandler = setShouldAddStorePaymentHandler
        self._fallbackHandler = fallbackHandler
    }

    public func canMakePayments() -> Bool {
        return _canMakePayments
    }

    public func addTransactionObserver() {
        _addTransactionObserverHandler?()
    }

    public func removeTransactionObserver() {
        _removeTransactionObserverHandler?()
    }

    public func restoreCompletedTransactions(handler: @escaping RestoreHandler) {
        _restoreHandler?(handler)
    }

    public func add(payment: SKPayment, handler: @escaping PaymentHandler) {
        _addPaymentHandler?(payment, handler)
    }

    public func set(shouldAddStorePaymentHandler: @escaping ShouldAddStorePaymentHandler) {
        _setShouldAddStorePaymentHandler?(shouldAddStorePaymentHandler)
    }

    public func addPaymentHandler(withProductIdentifier productIdentifier: String, handler: @escaping PaymentHandler) {
        _addProductIdentifierHandler?(productIdentifier, handler)
    }

    public func set(fallbackHandler: @escaping PaymentHandler) {
        _fallbackHandler?(fallbackHandler)
    }
}
