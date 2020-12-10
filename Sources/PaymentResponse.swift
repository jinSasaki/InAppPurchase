//
//  PaymentResponse.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2020/12/11.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import Foundation

public protocol PaymentResponse {
    var state: PaymentState { get }
    var transaction: PaymentTransaction { get }
}

typealias PublicPaymentTransaction = PaymentTransaction
extension Internal {
    internal struct PaymentResponse {
        internal let state: PaymentState
        internal let transaction: PublicPaymentTransaction
    }
}
extension Internal.PaymentResponse: PaymentResponse {}

extension Internal.PaymentResponse: Equatable {
    public static func == (lhs: Internal.PaymentResponse, rhs: Internal.PaymentResponse) -> Bool {
        return lhs.state == rhs.state && lhs.transaction.transactionIdentifier == rhs.transaction.transactionIdentifier
    }
}
