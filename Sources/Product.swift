//
//  Product.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import StoreKit

public struct Product {
    public let productIdentifier: String
    public let price: Int
    public let localizedTitle: String
    public let priceLocale: Locale

    internal init(_ product: SKProduct) {
        self.productIdentifier = product.productIdentifier
        self.price = product.price.intValue
        self.localizedTitle = product.localizedTitle
        self.priceLocale = product.priceLocale
    }
}
