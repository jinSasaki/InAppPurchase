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
    public let price: Decimal
    public let localizedTitle: String
    public let localizedDescription: String
    public let priceLocale: Locale
    public let isDownloadable: Bool
    public let downloadContentLengths: [NSNumber]
    public let downloadContentVersion: String
    public let subscriptionPeriod: ProductSubscriptionPeriod?

    internal init(_ product: SKProduct) {
        self.productIdentifier = product.productIdentifier
        self.price = product.price as Decimal
        self.localizedTitle = product.localizedTitle
        self.priceLocale = product.priceLocale
        self.localizedDescription = product.localizedDescription
        self.isDownloadable = product.isDownloadable
        self.downloadContentLengths = product.downloadContentLengths
        self.downloadContentVersion = product.downloadContentVersion
        if #available(iOS 11.2, *), let subscriptionPeriod = product.subscriptionPeriod {
            self.subscriptionPeriod = ProductSubscriptionPeriod(subscriptionPeriod)
        } else {
            self.subscriptionPeriod = nil
        }
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
