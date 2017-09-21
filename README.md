# InAppPurchase
[![Build Status](https://travis-ci.org/jinSasaki/in-app-purchase.svg?branch=master)](https://travis-ci.org/jinSasaki/in-app-purchase)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](https://codecov.io/gh/jinSasaki/in-app-purchase/branch/master/graph/badge.svg)](https://codecov.io/gh/jinSasaki/in-app-purchase)

A Simple and Lightweight framework for In App Purchase

## Feature
- Simple and Light :+1:
- Support [Promoting In-App Purchases](https://developer.apple.com/app-store/promoting-in-app-purchases/) :moneybag:
- No need to consider `StoreKit`! :sunglasses:
- High coverage and safe :white_check_mark:

## Installation

### Carthage
```
github "jinSasaki/InAppPurchase"
```

## Usage

### Setup Observer
**NOTE: This method should be called at launch.**

```swift
let iap = InAppPurchase.default
iap.addTransactionObserver()
```

**Promoting In App Purchases is available from iOS 11. `InAppPurchase` supports it!**
Add observer with `shouldAddStorePaymentHandler`.  
See also [`SKPaymentTransactionObserver#paymentQueue(_:shouldAddStorePayment:for:)`](https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue)and [Promoting In-App Purchases Guides](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/PromotingIn-AppPurchases/PromotingIn-AppPurchases.html#//apple_ref/doc/uid/TP40008267-CH11-SW1)

```swift
let iap = InAppPurchase.default
iap.addTransactionObserver(shouldAddStorePaymentHandler: { (product) -> Bool in
    // Return whether starting payment
}, purchaseHandler: { (result) in
    // Handle the result of payment added by Store
    // See also `InAppPurchase#purchase`
})
```

Stop payment observing if needed.

```swift
let iap = InAppPurchase.default
iap.removeTransactionObserver()
```

### Fetch Product Information
```swift
let iap = InAppPurchase.default
iap.fetchProduct(productIdentifiers: ["PRODUCT_ID"], handler: { (result) in
    switch result {
    case .success(let products):
        // Use products
    case .failure(let error):
        // Handle `InAppPurchase.Error`
    }
})
```

### Restore Completed Transaction
```swift
let iap = InAppPurchase.default
iap.restore(handler: { (result) in
    switch result {
    case .success:
        // Restored
    case .failure(let error):
        // Handle `InAppPurchase.Error`
    }
})
```

### Purchase

```swift
let iap = InAppPurchase.default
iap.purchase(productIdentifier: "PRODUCT_ID", finishDeferredTransactionHandler: { (result) in
    // `finishDeferredTransactionHandler` is called if the payment had been deferred and then approved.
    // For example, the case that a child requests to purchase, and then the parent approves.

    switch result {
    case .success(let state):
        // Handle `InAppPurchase.PaymentState` if needed
    case .failure(let error):
        // Handle `InAppPurchase.Error` if needed
    }
}, handler: { (result) in
    // This handler is called if the payment purchased, restored, deferred or failed.

    switch result {
    case .success(let state):
        // Handle `InAppPurchase.PaymentState`
    case .failure(let error):
        // Handle `InAppPurchase.Error`
    }
})
```

## For Dependency Injection

The purchase logic in the App should be safe and testable. 

For example, you implemented a class to execute In-App-Purchase as follows.

```swift
// PurchaseService.swift

import Foundation
import InAppPurchase

final class PurchaseService {
    static let shared = PurchaseService()

    func purchase() {
        // Purchase with `InAppPurchase`
        InAppPurchase.default.purchase(productIdentifier: ...) {
            // Do something            
        }
    }
}
```

It is hard to test this class because using the `InAppPurchase.default` in the purchase process.

This `PurchaseService` can be refactored to inject the dependency.  
Use `InAppPurchaseProvidable` protocol.

```swift
// PurchaseService.swift

import Foundation
import InAppPurchase

final class PurchaseService {
    static let shared = PurchaseService()

    let iap: InAppPurchaseProvidable

    init(iap: InAppPurchaseProvidable = InAppPurchase.default) {
        self.iap = iap
    }

    func purchase() {
        // Purchase with `InAppPurchase`
        iap.purchase(productIdentifier: ...) {
            // Do something            
        }
    }
}
```

And then you can test `PurchaseService` easily.

```swift
// PurchaseServiceTests.swift

import XCTest
@testable import YourApp

// Stub
final class StubInAppPurchase: InAppPurchaseProvidable {
    private let _purchaseHandler: ((_ productIdentifier: String, _ finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?, _ handler: InAppPurchase.PurchaseHandler?) -> Void)?

    init(purchaseHandler: ((_ productIdentifier: String, _ finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?, _ handler: InAppPurchase.PurchaseHandler?) -> Void)? = nil) {
        self._purchaseHandler = purchaseHandler
    }

    func purchase(productIdentifier: String, finishDeferredTransactionHandler: InAppPurchase.PurchaseHandler?, handler: InAppPurchase.PurchaseHandler?) {
        _purchaseHandler?(productIdentifier, finishDeferredTransactionHandler, handler)
    }
}

// Test
class PurchaseServiceTests: XCTestCase {
    func testPurchase() {
        let expectation = self.expectation(description: "purchase handler was called.")
        let iap = StubInAppPurchase(purchaseHandler: { productIdentifier, finishDeferredTransactionHandler , handler in
            // Assert productIdentifier, handler, and so on.
        })
        let purchaseService = PurchaseService(iap: iap)
        purchaseService.purchase(productIdentifier: ...) {
            // Assert result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
```

If you want more information for test, see also [Stubs](./Tests/Stubs/) and [Tests](./Tests/).

## Requirements
- iOS 9.0+
- Xcode 9+
- Swift 4+

## License
MIT
