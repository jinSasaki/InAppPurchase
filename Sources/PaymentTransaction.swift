//
//  PaymentTransaction.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public typealias TransactionState = SKPaymentTransactionState

public struct PaymentTransaction {
    var transactionIdentifier: String? {
        skTransaction.transactionIdentifier
    }
    var originalTransactionIdentifier: String? {
        skTransaction.original?.transactionIdentifier
    }
    var productIdentifier: String {
        skTransaction.payment.productIdentifier
    }

    internal let skTransaction: SKPaymentTransaction
    internal init(_ skTransaction: SKPaymentTransaction) {
        self.skTransaction = skTransaction
    }
}
