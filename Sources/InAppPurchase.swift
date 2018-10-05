//
//  InAppPurchase.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Public

public protocol InAppPurchaseProvidable {
    func canMakePayments() -> Bool
    func set(shouldAddStorePaymentHandler: ((_ product: Product) -> Bool)?, handler: InAppPurchase.PurchaseHandler?)
    func addTransactionObserver(fallbackHandler: InAppPurchase.PurchaseHandler?)
    func removeTransactionObserver()
    func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)?)
    func restore(handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?)
    func purchase(productIdentifier: String, handler: InAppPurchase.PurchaseHandler?)
}

final public class InAppPurchase {
    public typealias PurchaseHandler = (_ result: InAppPurchase.Result<PaymentState>) -> Void

    public enum Error: Swift.Error {
        case emptyProducts
        case invalid(productIds: [String])
        case paymentNotAllowed
        case paymentCancelled
        case storeProductNotAvailable
        case storeTrouble
        case with(error: Swift.Error)
        case unknown
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

    public static let `default` = InAppPurchase()

    fileprivate let productProvider: ProductProvidable
    fileprivate let paymentProvider: PaymentProvidable

    internal init(product: ProductProvidable = ProductProvider(), payment: PaymentProvidable = PaymentProvider()) {
        self.productProvider = product
        self.paymentProvider = payment
    }
}

extension InAppPurchase: InAppPurchaseProvidable {

    public func canMakePayments() -> Bool {
        return paymentProvider.canMakePayments()
    }

    public func set(shouldAddStorePaymentHandler: ((_ product: Product) -> Bool)? = nil, handler: InAppPurchase.PurchaseHandler?) {
        paymentProvider.set(shouldAddStorePaymentHandler: { [weak self] (queue, payment, product) -> Bool in
            let shouldAddStorePayment = shouldAddStorePaymentHandler?(Internal.Product(product)) ?? false
            if shouldAddStorePayment {
                self?.paymentProvider.addPaymentHandler(withProductIdentifier: payment.productIdentifier, handler: { (queue, result) in
                    switch result {
                    case .success(let transaction):
                        InAppPurchase.handle(
                            queue: queue,
                            transaction: transaction,
                            handler: handler
                        )
                    case .failure(let error):
                        handler?(.failure(error))
                    }
                })
            }
            return shouldAddStorePayment
        })
    }

    public func addTransactionObserver(fallbackHandler: InAppPurchase.PurchaseHandler? = nil) {
        paymentProvider.set(fallbackHandler: InAppPurchase.convertToFallbackHandler(from: fallbackHandler))
        paymentProvider.addTransactionObserver()
    }

    public func removeTransactionObserver() {
        paymentProvider.removeTransactionObserver()
    }

    public func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: InAppPurchase.Result<[Product]>) -> Void)? = nil) {
        productProvider.fetch(productIdentifiers: productIdentifiers, requestId: UUID().uuidString) { (result) in
            switch result {
            case .success(let products):
                handler?(.success(products.map({ Internal.Product($0) })))
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }

    public func restore(handler: ((_ result: InAppPurchase.Result<Void>) -> Void)?) {
        paymentProvider.restoreCompletedTransactions { (_, error) in
            if let error = error {
                handler?(.failure(error))
                return
            }
            handler?(.success(()))
        }
    }

    public func purchase(productIdentifier: String, handler: InAppPurchase.PurchaseHandler? = nil) {
        // Fetch product from App Store
        let requestId = UUID().uuidString
        productProvider.fetch(productIdentifiers: [productIdentifier], requestId: requestId) { [weak self] (result) in
            switch result {
            case .success(let products):
                guard let product = products.first else {
                    handler?(.failure(InAppPurchase.Error.emptyProducts))
                    return
                }

                // Add payment to App Store queue
                let payment = SKPayment(product: product)
                self?.paymentProvider.add(payment: payment, handler: { (queue, result) in
                    switch result {
                    case .success(let transaction):
                        InAppPurchase.handle(
                            queue: queue,
                            transaction: transaction,
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
