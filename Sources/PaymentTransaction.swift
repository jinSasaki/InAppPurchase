//
//  PaymentTransaction.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public struct PaymentTransaction {
    public enum State: Equatable {
        case purchasing
        case purchased
        case failed
        case restored
        case deferred
        case unknown(rawValue: Int)

        init(_ skState: SKPaymentTransactionState) {
            switch skState {
            case .purchasing: self = .purchasing
            case .purchased: self = .purchased
            case .failed: self = .failed
            case .deferred: self = .deferred
            case .restored: self = .restored
            @unknown default: self = .unknown(rawValue: skState.rawValue)
            }
        }
    }
    public var transactionIdentifier: String? {
        skTransaction.transactionIdentifier
    }
    public var originalTransactionIdentifier: String? {
        skTransaction.original?.transactionIdentifier
    }
    public var productIdentifier: String {
        skTransaction.payment.productIdentifier
    }
    public var state: State {
        PaymentTransaction.State(skTransaction.transactionState)
    }
    public var original: PaymentTransaction? {
        guard let original = skTransaction.original else {
            return nil
        }
        return .init(original)
    }

    internal let skTransaction: SKPaymentTransaction

    public init(_ skTransaction: SKPaymentTransaction) {
        self.skTransaction = skTransaction
    }
}
