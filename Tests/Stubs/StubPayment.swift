//
//  StubPayment.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final class StubPayment: SKPayment {
    private let _productIdentifier: String
    override var productIdentifier: String {
        return _productIdentifier
    }

    init(productIdentifier: String) {
        self._productIdentifier = productIdentifier
    }
}
