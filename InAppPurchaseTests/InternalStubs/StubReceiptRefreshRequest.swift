//
//  StubReceiptRefreshRequest.swift
//  InAppPurchaseTests
//
//  Created by Jin Sasaki on 2020/12/10.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

public final class StubReceiptRefreshRequest: SKReceiptRefreshRequest {
    private let _startHandler: () -> Void

    public init(startHandler: @escaping () -> Void) {
        self._startHandler = startHandler
        super.init()
    }

    public override func start() {
        _startHandler()
    }
}
