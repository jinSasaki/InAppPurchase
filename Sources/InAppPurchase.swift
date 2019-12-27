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
    func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: Result<[Product], InAppPurchase.Error>) -> Void)?)
    func restore(handler: ((_ result: Result<Set<String>, InAppPurchase.Error>) -> Void)?)
    func purchase(productIdentifier: String, handler: InAppPurchase.PurchaseHandler?)
}

final public class InAppPurchase {
    public typealias PurchaseHandler = (_ result: Result<PaymentState, InAppPurchase.Error>) -> Void

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

    public struct PaymentState {
        public enum State: Equatable {
            case purchased
            case deferred
            case restored
        }
        public let state: State
        public let transaction: PaymentTransaction
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
        paymentProvider.set(shouldAddStorePaymentHandler: { [weak self] (_, payment, product) -> Bool in
            let shouldAddStorePayment = shouldAddStorePaymentHandler?(Internal.Product(product)) ?? false
            if shouldAddStorePayment {
                self?.paymentProvider.addPaymentHandler(withProductIdentifier: payment.productIdentifier, handler: { (_, result) in
                    switch result {
                    case .success(let transaction):
                        InAppPurchase.handle(
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

    public func fetchProduct(productIdentifiers: Set<String>, handler: ((_ result: Result<[Product], InAppPurchase.Error>) -> Void)? = nil) {
        productProvider.fetch(productIdentifiers: productIdentifiers, requestId: UUID().uuidString) { (result) in
            switch result {
            case .success(let products):
                handler?(.success(products.map({ Internal.Product($0) })))
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }

    public func restore(handler: ((_ result: Result<Set<String>, InAppPurchase.Error>) -> Void)?) {
        paymentProvider.restoreCompletedTransactions { (queue, error) in
            if let error = error {
                handler?(.failure(error))
                return
            }
            let productIds = queue
                .transactions
                .filter({ $0.transactionState == .restored })
                .map({ $0.payment.productIdentifier })
            handler?(.success(Set<String>(productIds)))
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
                self?.paymentProvider.add(payment: payment, handler: { (_, result) in
                    switch result {
                    case .success(let transaction):
                        InAppPurchase.handle(
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
        return lhs.state == rhs.state && lhs.transaction.transactionIdentifier == rhs.transaction.transactionIdentifier
    }
}
