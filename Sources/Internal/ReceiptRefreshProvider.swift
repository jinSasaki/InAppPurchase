//
//  ReceiptRefreshProvider.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2020/12/10.
//  Copyright © 2020 Jin Sasaki. All rights reserved.
//

import Foundation
import StoreKit

final internal class ReceiptRefreshProvider: NSObject {
    fileprivate var requestHandlers: [String: ReceiptRefreshHandler] = [:]
    fileprivate lazy var dispatchQueue: DispatchQueue = DispatchQueue(label: String(describing: self))

    internal func makeRequest(requestId: String) -> SKRequest {
        let request = SKReceiptRefreshRequest()
        request.id = requestId
        request.delegate = self
        return request
    }
    internal func fetch(request: SKRequest, handler: @escaping ReceiptRefreshHandler) {
        dispatchQueue.async {
            self.requestHandlers[request.id] = handler
            DispatchQueue.main.async {
                request.start()
            }
        }
    }
}

extension ReceiptRefreshProvider: ReceiptRefreshProvidable {
    internal func refresh(requestId: String, handler: @escaping ReceiptRefreshHandler) {
        let request = makeRequest(requestId: requestId)
        fetch(request: request, handler: handler)
    }
}

// MARK: - SKProductsRequestDelegate

extension ReceiptRefreshProvider: SKRequestDelegate {
    internal func request(_ request: SKRequest, didFailWithError error: Error) {
        dispatchQueue.async {
            let handler = self.requestHandlers.removeValue(forKey: request.id)
            DispatchQueue.main.async {
                handler?(.failure(InAppPurchase.Error(transaction: nil, error: error)))
            }
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        dispatchQueue.async {
            let handler = self.requestHandlers.removeValue(forKey: request.id)
            DispatchQueue.main.async {
                handler?(.success(()))
            }
        }
    }
}
