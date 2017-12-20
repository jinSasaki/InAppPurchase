//
//  InAppPurchaseTests.swift
//  InAppPurchase
//
//  Created by Jin Sasaki on 2017/09/05.
//  Copyright © 2017年 Jin Sasaki. All rights reserved.
//

import XCTest
@testable import InAppPurchase
import StoreKit

class InAppPurchaseTests: XCTestCase {

    func testInAppPurchaseErrorInit() {
        func skError(code: SKError.Code) -> SKError {
            return SKError(_nsError: NSError(domain: SKErrorDomain, code: code.rawValue, userInfo: nil))
        }
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .paymentNotAllowed)), .paymentNotAllowed)
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .paymentCancelled)), .paymentCancelled)
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .storeProductNotAvailable)), .storeProductNotAvailable)
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .unknown)), .storeTrouble)
        let nsError = NSError(domain: "", code: 0, userInfo: nil)
        XCTAssertEqual(InAppPurchase.Error(error: nsError), .with(error: nsError))
        XCTAssertEqual(InAppPurchase.Error(error: nil), .unknown)
    }

    func testInAppPurchaseErrorEquatable() {
        XCTAssertEqual(InAppPurchase.Error.emptyProducts, .emptyProducts)
        XCTAssertEqual(InAppPurchase.Error.invalid(productIds: ["a"]), .invalid(productIds: ["a"]))
        XCTAssertNotEqual(InAppPurchase.Error.invalid(productIds: ["a"]), .invalid(productIds: ["b"]))
        XCTAssertNotEqual(InAppPurchase.Error.paymentNotAllowed, .paymentCancelled)
    }

    func testInAppPurchasePaymentStateEqutable() {
        XCTAssertEqual(InAppPurchase.PaymentState.deferred, InAppPurchase.PaymentState.deferred)
        XCTAssertEqual(InAppPurchase.PaymentState.restored, InAppPurchase.PaymentState.restored)
        XCTAssertNotEqual(InAppPurchase.PaymentState.deferred, InAppPurchase.PaymentState.restored)

        let transaction1 = PaymentTransaction(StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased, original: nil,
            payment: StubPayment(productIdentifier: "PRODUCT_001"),
            error: nil
        ))
        let transaction2 = PaymentTransaction(StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased, original: nil,
            payment: StubPayment(productIdentifier: "PRODUCT_001"),
            error: nil
        ))
        let transaction3 = PaymentTransaction(StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_002",
            transactionState: .purchased, original: nil,
            payment: StubPayment(productIdentifier: "PRODUCT_001"),
            error: nil
        ))
        XCTAssertEqual(InAppPurchase.PaymentState.purchased(transaction: transaction1), InAppPurchase.PaymentState.purchased(transaction: transaction2))
        XCTAssertNotEqual(InAppPurchase.PaymentState.purchased(transaction: transaction1), InAppPurchase.PaymentState.purchased(transaction: transaction3))
    }

    func testCanMakePayments() {
        func check(enabled: Bool) {
            let productProvider = StubProductProvider()
            let paymentProvider = StubPaymentProvider(canMakePayments: enabled)
            let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
            XCTAssertEqual(iap.canMakePayments(), enabled)
        }
        check(enabled: true)
        check(enabled: false)
    }

    func testAddTransactionObserverWhereSetShouldAddStorePaymentIsNil() {
        let expectation1 = self.expectation()
        let expectation2 = self.expectation()

        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let product = StubProduct(productIdentifier: "PRODUCT_001")

        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(addTransactionObserverHandler: {
            expectation1.fulfill()
        }, addProductIdentifierHandler: { _, _ in
            XCTFail()
        }, setShouldAddStorePaymentHandler: { handler in
            expectation2.fulfill()
            XCTAssertFalse(handler(queue, payment, product))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.addTransactionObserver(
            shouldAddStorePaymentHandler: nil,
            fallbackHandler: { _ in
                XCTFail()
        })
        wait(for: [expectation1, expectation2], timeout: 1)
    }

    func testAddTransactionObserverWhereSuccess() {
        let expectation1 = self.expectation()
        let expectation2 = self.expectation()
        let expectation3 = self.expectation()
        let expectation4 = self.expectation()

        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: nil,
            payment: payment
        )

        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(addTransactionObserverHandler: {
            expectation1.fulfill()
        }, addProductIdentifierHandler: { productIdentifier, handler in
            XCTAssertEqual(productIdentifier, "PRODUCT_001")
            expectation2.fulfill()
            handler(queue, .success(transaction))
        }, setShouldAddStorePaymentHandler: { handler in
            expectation3.fulfill()
            XCTAssertTrue(handler(queue, payment, product))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.addTransactionObserver(
            shouldAddStorePaymentHandler: { _ -> Bool in return true },
            fallbackHandler: { (result) in
                switch result {
                case .success(let state):
                    XCTAssertEqual(state, InAppPurchase.PaymentState.purchased(transaction: PaymentTransaction(transaction)))
                case .failure:
                    XCTFail()
                }
                expectation4.fulfill()
        })
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 1)
    }

    func testAddTransactionObserverWhereFailure() {
        let expectation1 = self.expectation()
        let expectation2 = self.expectation()
        let expectation3 = self.expectation()
        let expectation4 = self.expectation()
        let queue = StubPaymentQueue()

        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(addTransactionObserverHandler: {
            expectation1.fulfill()
        }, addProductIdentifierHandler: { productIdentifier, handler in
            XCTAssertEqual(productIdentifier, "PRODUCT_001")
            expectation2.fulfill()
            handler(queue, .failure(InAppPurchase.Error.storeTrouble))
        }, setShouldAddStorePaymentHandler: { handler in
            expectation3.fulfill()
            let paymet = StubPayment(productIdentifier: "PRODUCT_001")
            let product = StubProduct(productIdentifier: "PRODUCT_001")
            XCTAssertTrue(handler(queue, paymet, product))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.addTransactionObserver(
            shouldAddStorePaymentHandler: { _ -> Bool in return true },
            fallbackHandler: { (result) in
                switch result {
                case .success:
                    XCTFail()
                case .failure(let error):
                    XCTAssertEqual(error, InAppPurchase.Error.storeTrouble)
                }
                expectation4.fulfill()
        })
        wait(for: [expectation1, expectation2, expectation3, expectation4], timeout: 1)
    }

    func testRemoveTransactionObserver() {
        let expectation = self.expectation()
        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(removeTransactionObserverHandler: {
            expectation.fulfill()
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.removeTransactionObserver()
        wait(for: [expectation], timeout: 1)
    }

    func testFetchProduct() {
        let expectation = self.expectation()
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let productProvider = StubProductProvider(result: .success([product]))
        let paymentProvider = StubPaymentProvider()

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.fetchProduct(productIdentifiers: []) { (result) in
            switch result {
            case .success(let products):
                XCTAssertEqual(products.count, 1)
                XCTAssertEqual(products.first?.productIdentifier, "PRODUCT_001")
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchProductWhereFailure() {
        let expectation = self.expectation()
        let productProvider = StubProductProvider(result: .failure(.storeTrouble))
        let paymentProvider = StubPaymentProvider()

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.fetchProduct(productIdentifiers: []) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRestore() {
        let expectation = self.expectation()
        let productProvider = StubProductProvider()
        let queue = StubPaymentQueue()
        let paymentProvider = StubPaymentProvider(restoreHandler: { (handler) in
            handler(queue, nil)
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.restore { (result) in
            switch result {
            case .success:
                // Do nothing, this is success.
                break
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRestoreWhereFailure() {
        let expectation = self.expectation()
        let productProvider = StubProductProvider()
        let queue = StubPaymentQueue()
        let paymentProvider = StubPaymentProvider(restoreHandler: { (handler) in
            handler(queue, .storeTrouble)
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.restore { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testPurchase() {
        let expectation1 = self.expectation()
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let productProvider = StubProductProvider(result: .success([product]))
        let paymentProvider = StubPaymentProvider(addPaymentHandler: { (payment, handler) in
            XCTAssertEqual(payment.productIdentifier, "PRODUCT_001")

            let queue = StubPaymentQueue()
            let originalTransaction = StubPaymentTransaction(transactionIdentifier: "ORIGINAL_TRANSACTION_001", transactionState: .purchased, payment: payment)
            let transaction = StubPaymentTransaction(transactionIdentifier: "TRANSACTION_001", transactionState: .purchased, original: originalTransaction, payment: payment)
            handler(queue, .success(transaction))

            expectation1.fulfill()
        })

        let expectation2 = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(productIdentifier: "PRODUCT_001", handler: { (result) in
            switch result {
            case .success(let state):
                if case let .purchased(transaction) = state {
                    XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
                    XCTAssertEqual(transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
                } else {
                    XCTFail()
                }
            case .failure:
                XCTFail()
            }
            expectation2.fulfill()
        })
        wait(for: [expectation1, expectation2], timeout: 1)
    }

    func testPurchaseWhereEmptyProduct() {
        let productProvider = StubProductProvider(result: .success([]))
        let paymentProvider = StubPaymentProvider(addPaymentHandler: { _, _ in
            XCTFail()
        })

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(productIdentifier: "PRODUCT_001", handler: { (result) in
            switch result {
            case .failure(let error):
                let expression: Bool
                if case .emptyProducts = error {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            default:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testPurchaseWhereFailureFetchProduct() {
        let productProvider = StubProductProvider(result: .failure(.storeTrouble))
        let paymentProvider = StubPaymentProvider(addPaymentHandler: { _, _ in
            XCTFail()
        })

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(productIdentifier: "PRODUCT_001", handler: { (result) in
            switch result {
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            default:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testPurchaseWhereFailureAddPayment() {
        let expectation1 = self.expectation()
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let productProvider = StubProductProvider(result: .success([product]))
        let paymentProvider = StubPaymentProvider(addPaymentHandler: { (payment, handler) in
            XCTAssertEqual(payment.productIdentifier, "PRODUCT_001")

            let queue = StubPaymentQueue()
            handler(queue, .failure(.storeTrouble))

            expectation1.fulfill()
        })

        let expectation2 = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(productIdentifier: "PRODUCT_001", handler: { (result) in
            switch result {
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            default:
                XCTFail()
            }
            expectation2.fulfill()
        })
        wait(for: [expectation1, expectation2], timeout: 1)
    }

    func testConvertWhereSuccess() {
        let expectation = self.expectation()
        let purchaseHandler: InAppPurchase.PurchaseHandler = { result in
            switch result {
            case .success(let state):
                if case let .purchased(transaction) = state {
                    XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
                    XCTAssertEqual(transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
                } else {
                    XCTFail()
                }
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
        let fallbackHandler = InAppPurchase.convertToFallbackHandler(from: purchaseHandler)
        let originalTransaction = StubPaymentTransaction(transactionIdentifier: "ORIGINAL_TRANSACTION_001", transactionState: .purchased)
        let transaction = StubPaymentTransaction(transactionIdentifier: "TRANSACTION_001", transactionState: .purchased, original: originalTransaction)
        fallbackHandler(StubPaymentQueue(), .success(transaction))
        wait(for: [expectation], timeout: 1)
    }

    func testConvertWhereFailure() {
        let expectation = self.expectation()
        let purchaseHandler: InAppPurchase.PurchaseHandler = { result in
            switch result {
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            default:
                XCTFail()
            }
            expectation.fulfill()
        }
        let fallbackHandler = InAppPurchase.convertToFallbackHandler(from: purchaseHandler)
        fallbackHandler(StubPaymentQueue(), .failure(.storeTrouble))
        wait(for: [expectation], timeout: 1)
    }

    func testHandleWherePurchasing() {
        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider()
        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchasing,
            payment: payment
        )

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.handle(queue: queue, transaction: transaction, handler: { _ in
            XCTFail()
        })
    }

    func testHandleWherePurchased() {
        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider()
        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let originalTransaction = StubPaymentTransaction(
            transactionIdentifier: "ORIGINAL_TRANSACTION_001",
            transactionState: .purchased,
            payment: payment
        )
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased,
            original: originalTransaction,
            payment: payment
        )

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.handle(queue: queue, transaction: transaction, handler: { result in
            switch result {
            case .success(let state):
                if case let .purchased(transaction) = state {
                    XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
                    XCTAssertEqual(transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
                } else {
                    XCTFail()
                }
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testHandleWhereRestored() {
        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider()
        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            payment: payment
        )

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.handle(queue: queue, transaction: transaction, handler: { result in
            switch result {
            case .success(let state):
                XCTAssertEqual(state, .restored)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testHandleWhereDeferred() {
        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider()
        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .deferred,
            payment: payment
        )

        let expectation1 = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.handle(queue: queue, transaction: transaction, handler: { result in
            switch result {
            case .success(let state):
                XCTAssertEqual(state, .deferred)
            case .failure:
                XCTFail()
            }
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: 1)
    }

    func testHandleWhereFailed() {
        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider()
        let queue = StubPaymentQueue()

        let error = NSError(domain: "test", code: 500, userInfo: nil)
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .failed,
            payment: payment,
            error: error
        )

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.handle(queue: queue, transaction: transaction, handler: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if case let .with(err) = error {
                    let err = err as NSError
                    XCTAssertEqual(err.domain, "test")
                    XCTAssertEqual(err.code, 500)
                } else {
                    XCTFail()
                }
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
}

extension XCTestCase {
    func expectation(function: String = #function) -> XCTestExpectation {
        return self.expectation(description: "\(function)")
    }
}
