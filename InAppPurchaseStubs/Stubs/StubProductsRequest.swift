//
//  StubProductsRequest.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/11.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public final class StubProductsRequest: SKProductsRequest {
    private let _startHandler: () -> Void

    public init(startHandler: @escaping () -> Void) {
        self._startHandler = startHandler
        super.init()
    }

    public override func start() {
        _startHandler()
    }
}
