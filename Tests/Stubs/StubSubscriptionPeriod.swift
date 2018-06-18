//
//  StubSubscriptionPeriod.swift
//  InAppPurchaseTests
//
//  Created by Jin Sasaki on 2018/06/16.
//  Copyright © 2018年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 11.2, *)
final class StubSubscriptionPeriod: SKProductSubscriptionPeriod {
    private let _numberOfUnits: Int
    private let _unit: SKProduct.PeriodUnit

    init(numberOfUnits: Int, unit: SKProduct.PeriodUnit) {
        self._numberOfUnits = numberOfUnits
        self._unit = unit
    }

    override var numberOfUnits: Int {
        return self._numberOfUnits
    }

    override var unit: SKProduct.PeriodUnit {
        return self._unit
    }
}
