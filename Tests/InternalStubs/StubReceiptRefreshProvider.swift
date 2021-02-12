//
//  StubReceiptRefreshProvider.swift
//  InAppPurchaseTests
//
//  Created by Jin Sasakion 2020/12/10.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import Foundation
@testable import InAppPurchase
import StoreKit

public final class StubReceiptRefreshProvider: ReceiptRefreshProvidable {
    private let _result: Result<Void, InAppPurchase.Error>

    public init(result: Result<Void, InAppPurchase.Error> = .success(())) {
        self._result = result
    }

    public func refresh(requestId: String, handler: @escaping ReceiptRefreshHandler) {
        handler(_result)
    }
}
