//
//  AppDelegate.swift
//  InAppPurchaseSample
//
//  Created by Jin Sasaki on 2021/08/05.
//

import UIKit
import InAppPurchase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        InAppPurchase.default.addTransactionObserver { result in
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

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
