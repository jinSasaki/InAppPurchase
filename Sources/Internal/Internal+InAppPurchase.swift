//
//  Internal+InAppPurchase.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2018/10/05.
//  Copyright © 2018年 Jin Sasaki. All rights reserved.
//

import StoreKit

internal typealias ProductHandler = (_ result: InAppPurchase.Result<[SKProduct]>) -> Void
internal typealias PaymentHandler = (_ queue: SKPaymentQueue, _ result: InAppPurchase.Result<SKPaymentTransaction>) -> Void
internal typealias RestoreHandler = (_ queue: SKPaymentQueue, _ error: InAppPurchase.Error?) -> Void
internal typealias ShouldAddStorePaymentHandler = (_ queue: SKPaymentQueue, _ payment: SKPayment, _ product: SKProduct) -> Bool

internal protocol ProductProvidable {
    func fetch(productIdentifiers: Set<String>, requestId: String, handler: @escaping ProductHandler)
}

internal protocol PaymentProvidable {
    func canMakePayments() -> Bool
    func addTransactionObserver()
    func removeTransactionObserver()
    func restoreCompletedTransactions(handler: @escaping RestoreHandler)
    func add(payment: SKPayment, handler: @escaping PaymentHandler)
    func addPaymentHandler(withProductIdentifier: String, handler: @escaping PaymentHandler)
    func set(shouldAddStorePaymentHandler: @escaping ShouldAddStorePaymentHandler)
    func set(fallbackHandler: @escaping PaymentHandler)
}
extension InAppPurchase.Error {
    internal init(error: Swift.Error?) {
        switch (error as? SKError)?.code {
        case .paymentNotAllowed?:
            self = .paymentNotAllowed
        case .paymentCancelled?:
            self = .paymentCancelled
        case .storeProductNotAvailable?:
            self = .storeProductNotAvailable
        case .unknown?:
            self = .storeTrouble
        default:
            if let error = error {
                self = .with(error: error)
            } else {
                self = .unknown
            }
        }
    }
}
extension InAppPurchase {

    /// Convert deferred handler from PurchaseHandler to PaymentHandler
    internal static func convertToFallbackHandler(from handler: InAppPurchase.PurchaseHandler?) -> PaymentHandler {
        let fallbackHandler: PaymentHandler = { (_, result) in
            switch result {
            case .success(let transaction):
                handler?(.success(.purchased(transaction: Internal.PaymentTransaction(transaction))))
            case .failure(let error):
                handler?(.failure(error))
            }
        }
        return fallbackHandler
    }

    internal static func handle(queue: SKPaymentQueue, transaction: SKPaymentTransaction, handler: InAppPurchase.PurchaseHandler?) {
        switch transaction.transactionState {
        case .purchasing:
            // Do nothing
            break
        case .purchased:
            handler?(.success(.purchased(transaction: Internal.PaymentTransaction(transaction))))
        case .restored:
            handler?(.success(.restored))
        case .deferred:
            handler?(.success(.deferred))
        case .failed:
            handler?(.failure(InAppPurchase.Error(error: transaction.error)))
        }
    }
}
