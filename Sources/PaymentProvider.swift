//
//  PaymentProvider.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/06.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

protocol PaymentQueue {
    func canMakePayments() -> Bool
    func add(_ observer: SKPaymentTransactionObserver)
    func remove(_ observer: SKPaymentTransactionObserver)

    func add(_ payment: SKPayment)
    func restoreCompletedTransactions()
}

final internal class PaymentProvider: NSObject {

    fileprivate let paymentQueue: PaymentQueue
    fileprivate var paymentHandlers: [String: [PaymentHandler]] = [:]
    fileprivate var restoreHandlers: [RestoreHandler] = []
    fileprivate var finishDeferredTransactionHandlers: [DeferredHandler] = []
    fileprivate var shouldAddStorePaymentHandler: ShouldAddStorePaymentHandler?
    fileprivate lazy var dispatchQueue: DispatchQueue = DispatchQueue(label: String(describing: self))

    init(paymentQueue: PaymentQueue = SKPaymentQueue.default()) {
        self.paymentQueue = paymentQueue
    }
}

extension PaymentProvider: PaymentProvidable {
    internal func canMakePayments() -> Bool {
        return paymentQueue.canMakePayments()
    }

    internal func addTransactionObserver() {
        paymentQueue.add(self)
    }

    internal func removeTransactionObserver() {
        paymentQueue.remove(self)
    }

    internal func add(payment: SKPayment, handler: @escaping PaymentHandler) {
        addPaymentHandler(withProductIdentifier: payment.productIdentifier, handler: handler)
        DispatchQueue.main.async {
            self.paymentQueue.add(payment)
        }
    }

    internal func addPaymentHandler(withProductIdentifier productIdentifier: String, handler: @escaping PaymentHandler) {
        dispatchQueue.async {
            var handlers: [PaymentHandler] = self.paymentHandlers[productIdentifier] ?? []
            handlers.append(handler)
            self.paymentHandlers[productIdentifier] = handlers
        }
    }

    internal func restoreCompletedTransactions(handler: @escaping RestoreHandler) {
        dispatchQueue.async {
            self.restoreHandlers.append(handler)
            DispatchQueue.main.async {
                self.paymentQueue.restoreCompletedTransactions()
            }
        }
    }

    internal func add(finishDeferredTransactionHandler: @escaping DeferredHandler) {
        dispatchQueue.async {
            self.finishDeferredTransactionHandlers.append(finishDeferredTransactionHandler)
        }
    }

    internal func set(shouldAddStorePaymentHandler: @escaping ShouldAddStorePaymentHandler) {
        self.shouldAddStorePaymentHandler = shouldAddStorePaymentHandler
    }

    internal func executeDeferredHandler(transaction: SKPaymentTransaction) {
        dispatchQueue.async {
            let handlers = self.finishDeferredTransactionHandlers
            self.finishDeferredTransactionHandlers = []
            DispatchQueue.main.async {
                handlers.forEach({ $0(.success(transaction)) })
            }
        }
    }
}

extension PaymentProvider: SKPaymentTransactionObserver {
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                // Do nothing and skip
                continue
            case .purchased, .failed:
                self.executeDeferredHandler(transaction: transaction)
                fallthrough
            case .restored:
                queue.finishTransaction(transaction)
            case .deferred:
                break
            }

            dispatchQueue.async {
                let handlers = self.paymentHandlers.removeValue(forKey: transaction.payment.productIdentifier)
                DispatchQueue.main.async {
                    handlers?.forEach({ $0(queue, .success(transaction)) })
                }
            }
        }
    }

    internal func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        dispatchQueue.async {
            let handlers = self.restoreHandlers
            self.restoreHandlers = []
            DispatchQueue.main.async {
                handlers.forEach({ $0(queue, nil) })
            }
        }
    }

    internal func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        dispatchQueue.async {
            let handlers = self.restoreHandlers
            self.restoreHandlers = []
            DispatchQueue.main.async {
                handlers.forEach({ $0(queue, InAppPurchase.Error(error: error)) })
            }
        }
    }

    internal func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return shouldAddStorePaymentHandler?(queue, payment, product) ?? false
    }
}

// MARK: - SKPaymentQueue extension

extension SKPaymentQueue: PaymentQueue {
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}
