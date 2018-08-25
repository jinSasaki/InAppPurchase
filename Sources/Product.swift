//
//  Product.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import StoreKit

public struct Product {
    public var productIdentifier: String {
        return skProduct.productIdentifier
    }
    public var price: Decimal {
        return skProduct.price as Decimal
    }
    public var localizedTitle: String {
        return skProduct.localizedTitle
    }
    public var localizedDescription: String {
        return skProduct.localizedDescription
    }
    public var priceLocale: Locale {
        return skProduct.priceLocale
    }
    public var isDownloadable: Bool {
        return skProduct.isDownloadable
    }
    public var downloadContentLengths: [NSNumber] {
        return skProduct.downloadContentLengths
    }
    public var downloadContentVersion: String {
        return skProduct.downloadContentVersion
    }
    public var subscriptionPeriod: ProductSubscriptionPeriod? {
        guard #available(iOS 11.2, *), let subscriptionPeriod = skProduct.subscriptionPeriod else {
            return nil
        }
        return ProductSubscriptionPeriod(subscriptionPeriod)
    }
    private let skProduct: SKProduct

    internal init(_ skProduct: SKProduct) {
        self.skProduct = skProduct
    }
}

public struct ProductSubscriptionPeriod {
    public let numberOfUnits: Int
    public let unit: PeriodUnit

    @available(iOS 11.2, *)
    internal init(_ period: SKProductSubscriptionPeriod) {
        self.numberOfUnits = period.numberOfUnits
        self.unit = PeriodUnit(period.unit)
    }
}

public enum PeriodUnit {
    case day
    case week
    case month
    case year

    init(_ unit: SKProduct.PeriodUnit) {
        switch unit {
        case .day: self = .day
        case .week: self = .week
        case .month: self = .month
        case .year: self = .year
        }
    }
}
