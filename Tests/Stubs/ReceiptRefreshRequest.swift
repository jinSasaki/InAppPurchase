//
//  ReceiptRefreshRequest.swift
//  InAppPurchaseTests
//
//  Created by Jin Sasaki on 2020/12/10.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final class StubReceiptRefreshRequest: SKReceiptRefreshRequest {
    private let _startHandler: () -> Void

    init(startHandler: @escaping () -> Void) {
        self._startHandler = startHandler
        super.init()
    }

    override func start() {
        _startHandler()
    }
}
