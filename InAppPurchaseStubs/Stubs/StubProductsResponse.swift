//
//  StubProductsResponse.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public final class StubProductsResponse: SKProductsResponse {
    private let _products: [StubProduct]
    private let _invalidProductIdentifiers: [String]

    public init(products: [StubProduct], invalidProductIdentifiers: [String]) {
        self._products = products
        self._invalidProductIdentifiers = invalidProductIdentifiers
    }

    public override var products: [SKProduct] {
        return _products
    }

    public override var invalidProductIdentifiers: [String] {
        return _invalidProductIdentifiers
    }
}
