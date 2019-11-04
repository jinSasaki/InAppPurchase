//
//  Internal+InAppPurchase.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2018/10/05.
//  Copyright © 2018年 Jin Sasaki. All rights reserved.
//

import StoreKit

internal typealias ProductHandler = (_ result: Result<[SKProduct], InAppPurchase.Error>) -> Void
internal typealias PaymentHandler = (_ queue: SKPaymentQueue, _ result: Result<SKPaymentTransaction, InAppPurchase.Error>) -> Void
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
                handle(transaction: transaction, handler: handler)
            case .failure(let error):
                handler?(.failure(error))
            }
        }
        return fallbackHandler
    }

    internal static func handle(transaction: SKPaymentTransaction, handler: InAppPurchase.PurchaseHandler?) {
        switch transaction.transactionState {
        case .purchasing:
            // Do nothing
            break
        case .purchased:
            handler?(.success(.init(state: .purchased, transaction: Internal.PaymentTransaction(transaction))))
        case .restored:
            handler?(.success(.init(state: .restored, transaction: Internal.PaymentTransaction(transaction))))
        case .deferred:
            handler?(.success(.init(state: .deferred, transaction: Internal.PaymentTransaction(transaction))))
        case .failed:
            handler?(.failure(InAppPurchase.Error(error: transaction.error)))
        @unknown default:
            // Do nothing
            break
        }
    }
}
