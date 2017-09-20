//
//  InAppPurchase.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final public class InAppPurchase {
    static let `default`: InAppPurchaseProvidable = InAppPurchase()

    fileprivate let productProvider: ProductProvidable
    fileprivate let paymentProvider: PaymentProvidable

    internal init(product: ProductProvidable = ProductProvider(), payment: PaymentProvidable = PaymentProvider()) {
        self.productProvider = product
        self.paymentProvider = payment
    }

    public static func canMakePayments() -> Bool {
        return self.default.canMakePayments()
    }

    public static func addTransactionObserver(shouldAddStorePaymentHandler: ((_ product: Product) -> Bool)? = nil, purchaseHandler: InAppPurchase.PurchaseHandler? = nil) {
        self.default.addTransactionObserver(shouldAddStorePaymentHandler: shouldAddStorePaymentHandler, purchaseHandler: purchaseHandler)
    }

    public static func removeTransactionObserver() {
        self.default.removeTransactionObserver()
    }

    public static func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?) {
        self.default.fetchProduct(productIdentifiers: productIdentifiers, handler: handler)
    }

    public static func restore(handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?) {
        self.default.restore(handler: handler)
    }
    public static func purchase(productIdentifier: String, finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?, handler: InAppPurchase.PurchaseHandler?) {
        self.default.purchase(productIdentifier: productIdentifier, finishDeferredTransactionHandler: finishDeferredTransactionHandler, handler: handler)
    }
}

extension InAppPurchase {
    public typealias PurchaseHandler = (_ result: InAppPurchase.Result<PaymentState>) -> Void

    public enum Error {
        case emptyProducts
        case invalid(productIds: [String])
        case paymentNotAllowed
        case paymentCancelled
        case storeProductNotAvailable
        case storeTrouble
        case with(error: Swift.Error)
        case unknown

        init(error: Swift.Error?) {
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

    public enum Result<T> {
        case success(T)
        case failure(InAppPurchase.Error)
    }

    public enum PaymentState {
        case purchased(transaction: PaymentTransaction)
        case deferred
        case restored
    }
}

extension InAppPurchase.Error: Equatable {
    public static func == (lhs: InAppPurchase.Error, rhs: InAppPurchase.Error) -> Bool {
        switch (lhs, rhs) {
        case (.emptyProducts, .emptyProducts): return true
        case (.invalid(productIds: let ids1), .invalid(productIds: let ids2)): return ids1 == ids2
        case (.paymentNotAllowed, .paymentNotAllowed): return true
        case (.paymentCancelled, .paymentCancelled): return true
        case (.storeProductNotAvailable, .storeProductNotAvailable): return true
        case (.storeTrouble, .storeTrouble): return true
        case (.with(error: let error1), .with(error: let error2)): return (error1 as NSError) == (error2 as NSError)
        case (.unknown, .unknown): return true
        default: return false
        }
    }
}

extension InAppPurchase.PaymentState: Equatable {
    public static func == (lhs: InAppPurchase.PaymentState, rhs: InAppPurchase.PaymentState) -> Bool {
        switch (lhs, rhs) {
        case (.purchased(let transaction1), .purchased(let transaction2)): return transaction1.transactionIdentifier == transaction2.transactionIdentifier
        case (.deferred, .deferred): return true
        case (.restored, .restored): return true
        default: return false
        }
    }
}

internal typealias ProductHandler = (_ result: InAppPurchase.Result<[SKProduct]>) -> Void
internal typealias PaymentHandler = (_ queue: SKPaymentQueue, _ result: InAppPurchase.Result<SKPaymentTransaction>) -> Void
internal typealias RestoreHandler = (_ queue: SKPaymentQueue, _ error: InAppPurchase.Error?) -> Void
internal typealias DeferredHandler = (_ result: InAppPurchase.Result<SKPaymentTransaction>) -> Void
internal typealias ShouldAddStorePaymentHandler = (_ queue: SKPaymentQueue, _ payment: SKPayment, _ product: SKProduct) -> Bool

internal protocol InAppPurchaseProvidable {
    func canMakePayments() -> Bool
    func addTransactionObserver(shouldAddStorePaymentHandler: ((_ product: Product) -> Bool)?, purchaseHandler: InAppPurchase.PurchaseHandler?)
    func removeTransactionObserver()
    func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?)
    func restore(handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?)
    func purchase(productIdentifier: String, finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?, handler: InAppPurchase.PurchaseHandler?)
}

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
    func add(finishDeferredTransactionHandler: @escaping DeferredHandler)
}

extension InAppPurchase: InAppPurchaseProvidable {
    // MARK: - Internal methods

    internal func canMakePayments() -> Bool {
        return paymentProvider.canMakePayments()
    }

    internal func addTransactionObserver(shouldAddStorePaymentHandler: ((_ product: Product) -> Bool)?, purchaseHandler: InAppPurchase.PurchaseHandler?) {
        paymentProvider.set { [weak self] (queue, payment, product) -> Bool in
            let shouldAddStorePayment = shouldAddStorePaymentHandler?(Product(product)) ?? false
            if shouldAddStorePayment, let me = self {
                me.paymentProvider.addPaymentHandler(withProductIdentifier: payment.productIdentifier, handler: { (queue, result) in
                    switch result {
                    case .success(let transaction):
                        guard let me = self else {
                            purchaseHandler?(.failure(InAppPurchase.Error.unknown))
                            return
                        }
                        me.handle(
                            queue: queue,
                            transaction: transaction,
                            finishDeferredTransactionHandler: nil,
                            handler: purchaseHandler
                        )
                    case .failure(let error):
                        purchaseHandler?(.failure(error))
                    }
                })
            }
            return shouldAddStorePayment
        }

        paymentProvider.addTransactionObserver()
    }

    internal func removeTransactionObserver() {
        paymentProvider.removeTransactionObserver()
    }

    internal func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?) {
        productProvider.fetch(productIdentifiers: productIdentifiers, requestId: UUID().uuidString) { (result) in
            switch result {
            case .success(let products):
                handler?(.success(products.map({ Product($0) })))
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }

    internal func restore(handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?) {
        paymentProvider.restoreCompletedTransactions { (_, error) in
            if let error = error {
                handler?(.failure(error))
                return
            }
            handler?(.success(()))
        }
    }

    internal func purchase(productIdentifier: String, finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?, handler: InAppPurchase.PurchaseHandler?) {
        // Fetch product from App Store
        let requestId = UUID().uuidString
        productProvider.fetch(productIdentifiers: [productIdentifier], requestId: requestId) { [weak self] (result) in
            switch result {
            case .success(let products):
                guard let product = products.first else {
                    handler?(.failure(InAppPurchase.Error.emptyProducts))
                    return
                }
                let finishDeferredTransactionPaymentHandler = InAppPurchase.convert(finishDeferredTransactionHandler: finishDeferredTransactionHandler)

                guard let me = self else {
                    handler?(.failure(InAppPurchase.Error.unknown))
                    return
                }
                // Add payment to App Store queue
                let payment = SKPayment(product: product)
                me.paymentProvider.add(payment: payment, handler: { [weak self] (queue, result) in
                    switch result {
                    case .success(let transaction):
                        guard let me = self else {
                            handler?(.failure(InAppPurchase.Error.unknown))
                            return
                        }
                        me.handle(
                            queue: queue,
                            transaction: transaction,
                            finishDeferredTransactionHandler: finishDeferredTransactionPaymentHandler,
                            handler: handler
                        )
                    case .failure(let error):
                        handler?(.failure(error))
                    }
                })
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }

    /// Convert deferred handler from PurchaseHandler to PaymentHandler
    internal static func convert(finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?) -> DeferredHandler {
        let finishDeferredTransactionHandler: DeferredHandler = { (result) in
            switch result {
            case .success(let transaction):
                finishDeferredTransactionHandler?(.success(.purchased(transaction: PaymentTransaction(transaction))))
            case .failure(let error):
                finishDeferredTransactionHandler?(.failure(error))
            }
        }
        return finishDeferredTransactionHandler
    }

    internal func handle(queue: SKPaymentQueue, transaction: SKPaymentTransaction, finishDeferredTransactionHandler: DeferredHandler?, handler: InAppPurchase.PurchaseHandler?) {
        switch transaction.transactionState {
        case .purchasing:
            // Do nothing
            break
        case .purchased:
            handler?(.success(.purchased(transaction: PaymentTransaction(transaction))))
        case .restored:
            handler?(.success(.restored))
        case .deferred:
            if let finishDeferredTransactionHandler = finishDeferredTransactionHandler {
                paymentProvider.add(finishDeferredTransactionHandler: finishDeferredTransactionHandler)
            }
            handler?(.success(.deferred))
        case .failed:
            handler?(.failure(InAppPurchase.Error(error: transaction.error)))
        }
    }
}
