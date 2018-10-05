//
//  PaymentTransaction.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import StoreKit

public typealias TransactionState = SKPaymentTransactionState

public protocol PaymentTransaction {
    var transactionIdentifier: String? { get }
    var originalTransactionIdentifier: String? { get }
    var productIdentifier: String { get }
}

extension Internal {
    internal struct PaymentTransaction {
        let transactionIdentifier: String?
        let originalTransactionIdentifier: String?
        let productIdentifier: String
    }
}
extension Internal.PaymentTransaction: PaymentTransaction {}
extension Internal.PaymentTransaction {
    internal init(_ transaction: SKPaymentTransaction) {
        self.transactionIdentifier = transaction.transactionIdentifier
        self.originalTransactionIdentifier = transaction.original?.transactionIdentifier
        self.productIdentifier = transaction.payment.productIdentifier
    }
}
