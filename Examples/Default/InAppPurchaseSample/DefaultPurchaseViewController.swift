//
//  DefaultPurchaseViewController.swift
//  InAppPurchaseSample
//
//  Created by Jin Sasaki on 2021/08/05.
//

import UIKit
import InAppPurchase

final class DefaultPurchaseViewController: UIViewController {

    let iap = InAppPurchase.default

    @IBAction func tapPurchaseCoin() {
        let id = Constant.Product.coin
        iap.purchase(productIdentifier: id, handler: Self.handle(result:))
    }

    @IBAction func tapPurchaseFull() {
        let id = Constant.Product.full
        iap.purchase(productIdentifier: id, handler: Self.handle(result:))
    }

    @IBAction func tapPurchaseSubscription() {
        let id = Constant.Product.subscription
        iap.purchase(productIdentifier: id, handler: Self.handle(result:))
    }

    private static func handle(result: Result<PaymentResponse, InAppPurchase.Error>) {
        switch result {
        case .success(let response):
            switch response.state {
            case .purchased:
                print("[PURCHASED] \(response.transaction.transactionIdentifier ?? "nil")")
            case .restored:
                print("[RESTORED] \(response.transaction.transactionIdentifier ?? "nil")")
            case .deferred:
                print("[DEFERRED] \(response.transaction.transactionIdentifier ?? "nil")")
            }
        case .failure(let error):
            print(error)
        }
    }
}
