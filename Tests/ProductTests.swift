//
//  ProductTests.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase
import StoreKit

class ProductTests: XCTestCase {
    func testInit() {
        let period: Any?
        if #available(iOS 11.2, *) {
            period = StubSubscriptionPeriod(numberOfUnits: 1, unit: .day)
        } else {
            period = nil
        }
        let skProduct = StubProduct(
            productIdentifier: "PRODUCT_001",
            price: 100,
            localizedTitle: "PRODUCT_NAME_001",
            localizedDescription: "PRODUCT_DESCRIPTION_001",
            priceLocale: Locale(identifier: "locale_001"),
            isDownloadable: true,
            downloadContentLengths: [1, 2],
            downloadContentVersion: "DOWNLOAD_CONTENT_VERSION",
            subscriptionPeriod: period
        )
        let product = Internal.Product(skProduct)

        XCTAssertEqual(product.productIdentifier, "PRODUCT_001")
        XCTAssertEqual(product.price, 100)
        XCTAssertEqual(product.localizedTitle, "PRODUCT_NAME_001")
        XCTAssertEqual(product.localizedDescription, "PRODUCT_DESCRIPTION_001")
        XCTAssertEqual(product.priceLocale.identifier, "locale_001")
        XCTAssertEqual(product.isDownloadable, true)
        XCTAssertEqual(product.downloadContentLengths, [1, 2])
        XCTAssertEqual(product.downloadContentVersion, "DOWNLOAD_CONTENT_VERSION")
        if #available(iOS 11.2, *) {
            if let subscriptionPeriod = product.subscriptionPeriod {
                XCTAssertEqual(subscriptionPeriod.numberOfUnits, 1)
                XCTAssertEqual(subscriptionPeriod.unit, .day)
            } else {
                XCTFail()
            }
        } else {
            XCTAssertNil(product.subscriptionPeriod)
        }
    }

    func testInitWherePeriodIsNil() {
        let skProduct = StubProduct(
            productIdentifier: "PRODUCT_001",
            price: 100,
            localizedTitle: "PRODUCT_NAME_001",
            localizedDescription: "PRODUCT_DESCRIPTION_001",
            priceLocale: Locale(identifier: "locale_001"),
            isDownloadable: true,
            downloadContentLengths: [1, 2],
            downloadContentVersion: "DOWNLOAD_CONTENT_VERSION",
            subscriptionPeriod: nil
        )
        let product = Internal.Product(skProduct)

        XCTAssertEqual(product.productIdentifier, "PRODUCT_001")
        XCTAssertEqual(product.price, 100)
        XCTAssertEqual(product.localizedTitle, "PRODUCT_NAME_001")
        XCTAssertEqual(product.priceLocale.identifier, "locale_001")
        XCTAssertEqual(product.isDownloadable, true)
        XCTAssertEqual(product.downloadContentLengths, [1, 2])
        XCTAssertEqual(product.downloadContentVersion, "DOWNLOAD_CONTENT_VERSION")
        XCTAssertNil(product.subscriptionPeriod)
    }
}

class ProductSubscriptionPeriodTests: XCTestCase {
    func testInit() {
        guard #available(iOS 11.2, *) else {
            // Success on unsupported os.
            return
        }
        let skProduct = StubProduct(
            productIdentifier: "PRODUCT_001",
            price: 100,
            localizedTitle: "PRODUCT_NAME_001",
            localizedDescription: "PRODUCT_DESCRIPTION_001",
            priceLocale: Locale(identifier: "locale_001"),
            isDownloadable: true,
            downloadContentLengths: [1, 2],
            downloadContentVersion: "DOWNLOAD_CONTENT_VERSION",
            subscriptionPeriod: StubSubscriptionPeriod(numberOfUnits: 1, unit: .day)
        )
        let product = Internal.Product(skProduct)
        XCTAssertEqual(product.subscriptionPeriod?.numberOfUnits, 1)
        XCTAssertEqual(product.subscriptionPeriod?.unit, .day)
    }
}

class PeriodUnitTests: XCTestCase {
    func testInit() {
        guard #available(iOS 11.2, *) else {
            // Success on unsupported os.
            return
        }
        XCTAssertEqual(makePeriodUnit(periodUnit: .day), .day)
        XCTAssertEqual(makePeriodUnit(periodUnit: .week), .week)
        XCTAssertEqual(makePeriodUnit(periodUnit: .month), .month)
        XCTAssertEqual(makePeriodUnit(periodUnit: .year), .year)
    }

    @available(iOS 11.2, *)
    func makePeriodUnit(periodUnit: SKProduct.PeriodUnit) -> PeriodUnit? {
        let skProduct = StubProduct(
            productIdentifier: "PRODUCT_001",
            price: 100,
            localizedTitle: "PRODUCT_NAME_001",
            localizedDescription: "PRODUCT_DESCRIPTION_001",
            priceLocale: Locale(identifier: "locale_001"),
            isDownloadable: true,
            downloadContentLengths: [1, 2],
            downloadContentVersion: "DOWNLOAD_CONTENT_VERSION",
            subscriptionPeriod: StubSubscriptionPeriod(numberOfUnits: 1, unit: periodUnit)
        )
        return Internal.Product(skProduct).subscriptionPeriod?.unit
    }
}
