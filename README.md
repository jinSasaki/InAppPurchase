# InAppPurchase
[![Build Status](https://travis-ci.org/jinSasaki/in-app-purchase.svg?branch=master)](https://travis-ci.org/jinSasaki/in-app-purchase)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A Simple and Lightweight framework for In App Purchase



## Feature
- Simple and Light :+1:
- Support [Promoting In-App Purchases](https://developer.apple.com/app-store/promoting-in-app-purchases/) :moneybag:
- No need to consider `StoreKit`! :sunglasses:

## Installation

### Carthage
```
# Cartfile
github "jinSasaki/InAppPurchase"
```

## Usage

### Setup Observer

#### Start payment observing

```swift
InAppPurchase.addTransactionObserver()
```

**Promoting In App Purchases is available from iOS 11. `InAppPurchase` supports it!**
Add observer with `shouldAddStorePaymentHandler`. See also [`SKPaymentTransactionObserver#paymentQueue(_:shouldAddStorePayment:for:)`](https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue) and [Promoting In-App Purchases Guides](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/PromotingIn-AppPurchases/PromotingIn-AppPurchases.html#//apple_ref/doc/uid/TP40008267-CH11-SW1)

```swift
InAppPurchase..addTransactionObserver(shouldAddStorePaymentHandler: { (product) -> Bool in
    // Return whether starting payment
}, purchaseHandler: { (result) in
    // Handle the result of payment added by Store
    // See also `InAppPurchase#purchase`
})
```

#### Stop payment observing

```swift
InAppPurchase.removeTransactionObserver()
```

### Fetch Product Information
```swift
InAppPurchase..fetchProduct(productIdentifiers: ["PRODUCT_ID"], handler: { (result) in
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
InAppPurchase.restore(handler: { (result) in
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
InAppPurchase.purchase(productIdentifier: "", finishDeferredTransactionHandler: { (result) in
    // `finishDeferredTransactionHandler` is called if the payment had been deferred and then approved.
    // For example, the case that a child requests to purchase, and then the parent approves.

    switch result {
    case .success(let state):
        // Handle `InAppPurchase.PaymentState`
    case .failure(let error):
        // Handle `InAppPurchase.Error`
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

## Requirements
- iOS 9.0+
- Xcode 9+
- Swift 4+
