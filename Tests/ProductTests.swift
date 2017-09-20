//
//  ProductTests.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase

class ProductTests: XCTestCase {
    func testInit() {
        let skProduct = StubProduct(
            productIdentifier: "PRODUCT_001",
            price: 100,
            localizedTitle: "PRODUCT_NAME_001",
            priceLocale: Locale(identifier: "locale_001")
        )
        let product = Product(skProduct)

        XCTAssertEqual(product.productIdentifier, "PRODUCT_001")
        XCTAssertEqual(product.price, 100)
        XCTAssertEqual(product.localizedTitle, "PRODUCT_NAME_001")
        XCTAssertEqual(product.priceLocale.identifier, "locale_001")
    }
}
