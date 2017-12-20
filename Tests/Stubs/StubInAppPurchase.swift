//
//  StubInAppPurchase.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

@testable import InAppPurchase

final class StubInAppPurchase: InAppPurchaseProvidable {
    private let _canMakePayments: Bool
    private let _addTransactionObserverHandler: ((_ shouldAddStorePaymentHandler: ((Product) -> Bool)?, _ fallbackHandler: InAppPurchase.PurchaseHandler?) -> Void)?
    private let _removeTransactionObserverHandler: (() -> Void)?
    private let _fetchProductHandler: ((_ productIdentifiers: Set<String>, _ handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?) -> Void)?
    private let _restoreHandler: ((_ handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?) -> Void)?
    private let _purchaseHandler: ((_ productIdentifier: String, _ handler: InAppPurchase.PurchaseHandler?) -> Void)?

    init(canMakePayments: Bool = true,
         addTransactionObserverHandler: ((_ shouldAddStorePaymentHandler: ((Product) -> Bool)?, _ fallbackHandler: InAppPurchase.PurchaseHandler?) -> Void)? = nil,
         removeTransactionObserverHandler: (() -> Void)? = nil,
         fetchProductHandler: ((_ productIdentifiers: Set<String>, _ handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?) -> Void)? = nil,
         restoreHandler: ((_ handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?) -> Void)? = nil,
         purchaseHandler: ((_ productIdentifier: String, _ handler: InAppPurchase.PurchaseHandler?) -> Void)? = nil) {

        self._canMakePayments = canMakePayments
        self._addTransactionObserverHandler = addTransactionObserverHandler
        self._removeTransactionObserverHandler = removeTransactionObserverHandler
        self._fetchProductHandler = fetchProductHandler
        self._restoreHandler = restoreHandler
        self._purchaseHandler = purchaseHandler
    }

    func canMakePayments() -> Bool {
        return _canMakePayments
    }

    func addTransactionObserver(shouldAddStorePaymentHandler: ((Product) -> Bool)?, fallbackHandler: InAppPurchase.PurchaseHandler?) {
        _addTransactionObserverHandler?(shouldAddStorePaymentHandler, fallbackHandler)
    }

    func removeTransactionObserver() {
        _removeTransactionObserverHandler?()
    }

    func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?) {
        _fetchProductHandler?(productIdentifiers, handler)
    }

    func restore(handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?) {
        _restoreHandler?(handler)
    }

    func purchase(productIdentifier: String, handler: InAppPurchase.PurchaseHandler?) {
        _purchaseHandler?(productIdentifier, handler)
    }
}
