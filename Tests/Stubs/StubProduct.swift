//
//  StubProduct.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final class StubProduct: SKProduct {
    private let _productIdentifier: String
    private let _price: Int
    private let _localizedTitle: String
    private let _priceLocale: Locale

    init(productIdentifier: String, price: Int = 0, localizedTitle: String = "", priceLocale: Locale = Locale(identifier: "")) {
        self._productIdentifier = productIdentifier
        self._price = price
        self._localizedTitle = localizedTitle
        self._priceLocale = priceLocale
    }

    override var productIdentifier: String {
        return _productIdentifier
    }

    override var price: NSDecimalNumber {
        return NSDecimalNumber(value: _price)
    }

    override var localizedTitle: String {
        return _localizedTitle
    }

    override var priceLocale: Locale {
        return _priceLocale
    }
}
