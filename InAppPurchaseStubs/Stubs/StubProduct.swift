//
//  StubProduct.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public final class StubProduct: SKProduct {
    private let _productIdentifier: String
    private let _price: Decimal
    private let _localizedTitle: String
    private let _localizedDescription: String
    private let _priceLocale: Locale
    private let _isDownloadable: Bool
    private let _downloadContentLengths: [NSNumber]
    private let _downloadContentVersion: String
    private let _subscriptionPeriod: Any?

    public init(
        productIdentifier: String,
        price: Decimal = 0,
        localizedTitle: String = "",
        localizedDescription: String = "",
        priceLocale: Locale = Locale(identifier: ""),
        isDownloadable: Bool = false,
        downloadContentLengths: [NSNumber] = [],
        downloadContentVersion: String = "",
        subscriptionPeriod: Any? = nil
        ) {
        self._productIdentifier = productIdentifier
        self._price = price
        self._localizedTitle = localizedTitle
        self._priceLocale = priceLocale
        self._localizedDescription = localizedDescription
        self._isDownloadable = isDownloadable
        self._downloadContentLengths = downloadContentLengths
        self._downloadContentVersion = downloadContentVersion
        self._subscriptionPeriod = subscriptionPeriod
    }

    public override var productIdentifier: String {
        return _productIdentifier
    }

    public override var price: NSDecimalNumber {
        return NSDecimalNumber(decimal: _price)
    }

    public override var localizedTitle: String {
        return _localizedTitle
    }

    public override var localizedDescription: String {
        return _localizedDescription
    }

    public override var priceLocale: Locale {
        return _priceLocale
    }

    public override var isDownloadable: Bool {
        return _isDownloadable
    }

    public override var downloadContentLengths: [NSNumber] {
        return _downloadContentLengths
    }

    public override var downloadContentVersion: String {
        return _downloadContentVersion
    }

    @available(iOS 11.2, *)
    public override var subscriptionPeriod: SKProductSubscriptionPeriod? {
        return _subscriptionPeriod as? SKProductSubscriptionPeriod
    }
}
