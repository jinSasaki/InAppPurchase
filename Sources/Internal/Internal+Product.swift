//
//  Internal+Product.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2018/10/05.
//  Copyright © 2018年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

extension Internal {
    struct Product {
        private let skProduct: SKProduct

        init(_ skProduct: SKProduct) {
            self.skProduct = skProduct
        }
    }
}
extension Internal.Product: Product {
    var productIdentifier: String {
        return skProduct.productIdentifier
    }
    var price: Decimal {
        return skProduct.price as Decimal
    }
    var localizedTitle: String {
        return skProduct.localizedTitle
    }
    var localizedDescription: String {
        return skProduct.localizedDescription
    }
    var priceLocale: Locale {
        return skProduct.priceLocale
    }
    var isDownloadable: Bool {
        return skProduct.isDownloadable
    }
    var downloadContentLengths: [NSNumber] {
        return skProduct.downloadContentLengths
    }
    var downloadContentVersion: String {
        return skProduct.downloadContentVersion
    }
    var subscriptionPeriod: ProductSubscriptionPeriod? {
        guard #available(iOS 11.2, *), let subscriptionPeriod = skProduct.subscriptionPeriod else {
            return nil
        }
        return Internal.ProductSubscriptionPeriod(subscriptionPeriod)
    }
    var discounts: [ProductDiscount] {
        guard #available(iOS 12.2, *) else {
            return []
        }
        return skProduct.discounts.map { Internal.ProductDiscount($0) }
    }
}

extension Internal {
    @available(iOS 12.2, *)
    struct ProductDiscount {
        private let skProductDiscount: SKProductDiscount

        init(_ skProductDiscount: SKProductDiscount) {
            self.skProductDiscount = skProductDiscount
        }
    }
}

extension Internal {
    struct ProductSubscriptionPeriod {
        let numberOfUnits: Int
        let unit: PeriodUnit

        @available(iOS 11.2, *)
        init?(_ period: SKProductSubscriptionPeriod) {
            guard let unit = PeriodUnit(period.unit) else {
                return nil
            }
            self.numberOfUnits = period.numberOfUnits
            self.unit = unit
        }
    }
}
extension Internal.ProductSubscriptionPeriod: ProductSubscriptionPeriod {}

extension PeriodUnit {
    @available(iOS 11.2, *)
    init?(_ unit: SKProduct.PeriodUnit) {
        switch unit {
        case .day: self = .day
        case .week: self = .week
        case .month: self = .month
        case .year: self = .year
        @unknown default: return nil
        }
    }
}

@available(iOS 12.2, *)
extension Internal.ProductDiscount: ProductDiscount {
    var offerIdentifier: String? {
        return skProductDiscount.identifier
    }

    var type: ProductDiscountType? {
        return ProductDiscountType(skProductDiscount.type)
    }

    var price: Decimal {
        return skProductDiscount.price as Decimal
    }

    var priceLocale: Locale {
        return skProductDiscount.priceLocale
    }

    var paymentMode: ProductDiscountPaymentMode? {
        return ProductDiscountPaymentMode(skProductDiscount.paymentMode)
    }

    var numberOfPeriods: Int {
        return skProductDiscount.numberOfPeriods
    }

    var subscriptionPeriod: ProductSubscriptionPeriod? {
        let period: SKProductSubscriptionPeriod = skProductDiscount.subscriptionPeriod
        return Internal.ProductSubscriptionPeriod(period)
    }
}

@available(iOS 12.2, *)
extension ProductDiscountType {
    init?(_ type: SKProductDiscount.`Type`) {
        switch type {
        case .introductory: self = .introductory
        case .subscription: self = .subscription
        @unknown default: return nil
        }
    }
}

@available(iOS 11.2, *)
extension ProductDiscountPaymentMode {
    init?(_ paymentMode: SKProductDiscount.PaymentMode) {
        switch paymentMode {
        case .freeTrial: self = .freeTrial
        case .payAsYouGo: self = .payAsYouGo
        case .payUpFront: self = .payUpFront
        @unknown default: return nil
        }
    }
}
