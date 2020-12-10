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
public final class StubSubscriptionPeriod: SKProductSubscriptionPeriod {
    private let _numberOfUnits: Int
    private let _unit: SKProduct.PeriodUnit

    public init(numberOfUnits: Int, unit: SKProduct.PeriodUnit) {
        self._numberOfUnits = numberOfUnits
        self._unit = unit
    }

    public override var numberOfUnits: Int {
        return self._numberOfUnits
    }

    public override var unit: SKProduct.PeriodUnit {
        return self._unit
    }
}
