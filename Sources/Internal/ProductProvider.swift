//
//  ProductProvider.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/04/06.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final internal class ProductProvider: NSObject {
    fileprivate var requestHandlers: [String: ProductHandler] = [:]
    fileprivate lazy var dispatchQueue: DispatchQueue = DispatchQueue(label: String(describing: self))

    internal func fetch(productIdentifiers: Set<String>, requestId: String, handler: @escaping ProductHandler) {
        let request = makeRequest(productIdentifiers: productIdentifiers, requestId: requestId)
        fetch(request: request, handler: handler)
    }

    internal func makeRequest(productIdentifiers: Set<String>, requestId: String) -> SKProductsRequest {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.id = requestId
        request.delegate = self
        return request
    }
}

extension ProductProvider: ProductProvidable {
    internal func fetch(request: SKProductsRequest, handler: @escaping ProductHandler) {
        dispatchQueue.async {
            self.requestHandlers[request.id] = handler
            DispatchQueue.main.async {
                request.start()
            }
        }
    }
}

// MARK: - SKProductsRequestDelegate

extension ProductProvider: SKProductsRequestDelegate {
    internal func request(_ request: SKRequest, didFailWithError error: Error) {
        dispatchQueue.async {
            let handler = self.requestHandlers.removeValue(forKey: request.id)
            DispatchQueue.main.async {
                handler?(.failure(InAppPurchase.Error(error: error)))
            }
        }
    }

    internal func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        dispatchQueue.async {
            let handler = self.requestHandlers.removeValue(forKey: request.id)
            guard response.invalidProductIdentifiers.isEmpty else {
                DispatchQueue.main.async {
                    handler?(.failure(InAppPurchase.Error.invalid(productIds: response.invalidProductIdentifiers)))
                }
                return
            }
            DispatchQueue.main.async {
                handler?(.success(response.products))
            }
        }
    }
}

// MARK: - SKRequest extension

private var requestIdKey: UInt = 0
internal extension SKRequest {
    var id: String {
        get {
            return objc_getAssociatedObject(self, &requestIdKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &requestIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
