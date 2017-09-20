//
//  PaymentTransaction.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import StoreKit

public struct PaymentTransaction {
    public let transactionIdentifier: String?
    public let originalTransactionIdentifier: String?
    public let productIdentifier: String

    internal init(_ transaction: SKPaymentTransaction) {
        self.transactionIdentifier = transaction.transactionIdentifier
        self.originalTransactionIdentifier = transaction.original?.transactionIdentifier
        self.productIdentifier = transaction.payment.productIdentifier
    }
}
