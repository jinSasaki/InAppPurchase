//
//  PaymentState.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2020/12/11.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import Foundation

public enum PaymentState: Equatable {
    case purchased
    case deferred
    case restored
    case failed
}
