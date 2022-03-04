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
import InAppPurchaseStubs

class InAppPurchaseErrorTests: XCTestCase {
    func testInAppPurchaseErrorInit() {
        func skError(code: SKError.Code) -> SKError {
            return SKError(_nsError: NSError(domain: SKErrorDomain, code: code.rawValue, userInfo: nil))
        }
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .paymentNotAllowed)).code, .paymentNotAllowed)
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .paymentCancelled)).code, .paymentCancelled)
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .storeProductNotAvailable)).code, .storeProductNotAvailable)
        XCTAssertEqual(InAppPurchase.Error(error: skError(code: .unknown)).code, .storeTrouble)
        let nsError = NSError(domain: "", code: 0, userInfo: nil)
        XCTAssertEqual(InAppPurchase.Error(error: nsError).code, .with(error: nsError))
        XCTAssertEqual(InAppPurchase.Error(error: nil).code, .unknown)
    }

    func testInAppPurchaseErrorDomain() {
        XCTAssertEqual((InAppPurchase.Error(code: .emptyProducts, transaction: nil) as NSError).domain, "InAppPurchase.Error")
    }

    func testInAppPurchaseErrorCode() {
        XCTAssertEqual(InAppPurchase.Error(code: .emptyProducts, transaction: nil).errorCode, 0)
        XCTAssertEqual(InAppPurchase.Error(code: .invalid(productIds: []), transaction: nil).errorCode, 1)
        XCTAssertEqual(InAppPurchase.Error(code: .paymentNotAllowed, transaction: nil).errorCode, 2)
        XCTAssertEqual(InAppPurchase.Error(code: .paymentCancelled, transaction: nil).errorCode, 3)
        XCTAssertEqual(InAppPurchase.Error(code: .storeProductNotAvailable, transaction: nil).errorCode, 4)
        XCTAssertEqual(InAppPurchase.Error(code: .storeTrouble, transaction: nil).errorCode, 5)
        let nsError = NSError(domain: "", code: 100, userInfo: nil)
        XCTAssertEqual(InAppPurchase.Error(error: nsError).errorCode, 100)
        XCTAssertEqual(InAppPurchase.Error(code: .unknown, transaction: nil).errorCode, 999)
    }

    func testInAppPurchaseErrorCodeEquatable() {
        XCTAssertEqual(InAppPurchase.Error.Code.emptyProducts, .emptyProducts)
        XCTAssertEqual(InAppPurchase.Error.Code.invalid(productIds: ["a"]), .invalid(productIds: ["a"]))
        XCTAssertNotEqual(InAppPurchase.Error.Code.invalid(productIds: ["a"]), .invalid(productIds: ["b"]))
        XCTAssertNotEqual(InAppPurchase.Error.Code.paymentNotAllowed, .paymentCancelled)
    }

    func testInAppPurchaseErrorEquatable() {
        let transaction1 = PaymentTransaction(StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchased, original: nil,
            payment: StubPayment(productIdentifier: "PRODUCT_001"),
            error: nil
        ))
        let transaction2 = PaymentTransaction(StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_002",
            transactionState: .purchased, original: nil,
            payment: StubPayment(productIdentifier: "PRODUCT_002"),
            error: nil
        ))
        XCTAssertEqual(InAppPurchase.Error(code: .emptyProducts, transaction: nil), InAppPurchase.Error(code: .emptyProducts, transaction: nil))
        XCTAssertEqual(InAppPurchase.Error(code: .storeTrouble, transaction: transaction1), InAppPurchase.Error(code: .storeTrouble, transaction: transaction1))
        XCTAssertNotEqual(InAppPurchase.Error(code: .emptyProducts, transaction: nil), InAppPurchase.Error(code: .storeTrouble, transaction: nil))
        XCTAssertNotEqual(InAppPurchase.Error(code: .storeTrouble, transaction: transaction1), InAppPurchase.Error(code: .storeTrouble, transaction: transaction2))
    }
}

class InAppPurchaseTests: XCTestCase {

    func testInAppPurchasePaymentStateEqutable() {
        XCTAssertEqual(PaymentState.deferred, PaymentState.deferred)
        XCTAssertEqual(PaymentState.restored, PaymentState.restored)
        XCTAssertNotEqual(PaymentState.deferred, PaymentState.restored)

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
        XCTAssertEqual(Internal.PaymentResponse(state: .purchased, transaction: transaction1), Internal.PaymentResponse(state: .purchased, transaction: transaction2))
        XCTAssertNotEqual(Internal.PaymentResponse(state: .purchased, transaction: transaction1), Internal.PaymentResponse(state: .purchased, transaction: transaction3))
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

    func testSetShouldAddStorePaymentWhereIsNil() {
        let expectation = self.expectation()

        let queue = StubPaymentQueue()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let product = StubProduct(productIdentifier: "PRODUCT_001")

        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(addProductIdentifierHandler: { _, _ in
            XCTFail()
        }, setShouldAddStorePaymentHandler: { handler in
            expectation.fulfill()
            XCTAssertFalse(handler(queue, payment, product))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.set(
            shouldAddStorePaymentHandler: nil,
            handler: { _ in
            XCTFail()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testSetShouldAddStorePaymentWhereSuccess() {
        let expectation1 = self.expectation()
        let expectation2 = self.expectation()
        let expectation3 = self.expectation()

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
        let paymentProvider = StubPaymentProvider(addProductIdentifierHandler: { productIdentifier, handler in
            XCTAssertEqual(productIdentifier, "PRODUCT_001")
            expectation1.fulfill()
            handler(queue, .success(transaction))
        }, setShouldAddStorePaymentHandler: { handler in
            expectation2.fulfill()
            XCTAssertTrue(handler(queue, payment, product))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.set(
            shouldAddStorePaymentHandler: { _ -> Bool in return true },
            handler: { (result) in
                switch result {
                case .success(let response):
                    let expected = Internal.PaymentResponse(state: .purchased, transaction: PaymentTransaction(transaction))
                    XCTAssertEqual(response.state, expected.state)
                    XCTAssertEqual(response.transaction.transactionIdentifier, expected.transaction.transactionIdentifier)
                case .failure:
                    XCTFail()
                }
                expectation3.fulfill()
        })
        wait(for: [expectation1, expectation2, expectation3], timeout: 1)
    }

    func testSetShouldAddStorePaymentWhereFailure() {
        let expectation1 = self.expectation()
        let expectation2 = self.expectation()
        let expectation3 = self.expectation()
        let queue = StubPaymentQueue()

        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(addProductIdentifierHandler: { productIdentifier, handler in
            XCTAssertEqual(productIdentifier, "PRODUCT_001")
            expectation1.fulfill()
            handler(queue, .failure(.init(code: .storeTrouble, transaction: nil)))
        }, setShouldAddStorePaymentHandler: { handler in
            expectation2.fulfill()
            let paymet = StubPayment(productIdentifier: "PRODUCT_001")
            let product = StubProduct(productIdentifier: "PRODUCT_001")
            XCTAssertTrue(handler(queue, paymet, product))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.set(
            shouldAddStorePaymentHandler: { _ -> Bool in return true },
            handler: { (result) in
                switch result {
                case .success:
                    XCTFail()
                case .failure(let error):
                    XCTAssertEqual(error.code, .storeTrouble)
                }
                expectation3.fulfill()
        })
        wait(for: [expectation1, expectation2, expectation3], timeout: 1)
    }

    func testAddTransactionObserver() {
        let expectation1 = self.expectation()
        let expectation2 = self.expectation()

        let productProvider = StubProductProvider()
        let paymentProvider = StubPaymentProvider(addTransactionObserverHandler: {
            expectation1.fulfill()
        }, fallbackHandler: { _ in
            expectation2.fulfill()
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.addTransactionObserver(
            fallbackHandler: { _ in
                XCTFail()
        })
        wait(for: [expectation1, expectation2], timeout: 1)
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
        iap.fetchProduct(productIdentifiers: ["PRODUCT_001"]) { (result) in
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
        let productProvider = StubProductProvider(result: .failure(.init(code: .storeTrouble, transaction: nil)))
        let paymentProvider = StubPaymentProvider()

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.fetchProduct(productIdentifiers: []) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error.code {
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
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction1 = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: nil,
            payment: payment,
            error: nil
        )
        let transaction2 = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_002",
            transactionState: .purchased,
            original: nil,
            payment: payment,
            error: nil
        )
        let queue = StubPaymentQueue(transactions: [transaction1, transaction2])
        let paymentProvider = StubPaymentProvider(restoreHandler: { (handler) in
            handler(queue, nil)
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.restore { (result) in
            switch result {
            case .success(let productIds):
                XCTAssertEqual(productIds, ["PRODUCT_001"])
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
            handler(queue, .init(code: .storeTrouble, transaction: nil))
        })

        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.restore { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error.code {
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
                XCTAssertEqual(state.state, .purchased)
                XCTAssertEqual(state.transaction.transactionIdentifier, "TRANSACTION_001")
                XCTAssertEqual(state.transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
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
                if case .emptyProducts = error.code {
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
        let productProvider = StubProductProvider(result: .failure(.init(code: .storeTrouble, transaction: nil)))
        let paymentProvider = StubPaymentProvider(addPaymentHandler: { _, _ in
            XCTFail()
        })

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(productIdentifier: "PRODUCT_001", handler: { (result) in
            switch result {
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error.code {
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
            handler(queue, .failure(.init(code: .storeTrouble, transaction: nil)))

            expectation1.fulfill()
        })

        let expectation2 = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(productIdentifier: "PRODUCT_001", handler: { (result) in
            switch result {
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error.code {
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

    func testPurchaseWithPaymentBuilder() {
        let expectation1 = self.expectation()
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let productProvider = StubProductProvider(result: .success([product]))
        let paymentProvider = StubPaymentProvider(addPaymentHandler: { (payment, handler) in
            XCTAssertEqual(payment.productIdentifier, "PRODUCT_001")
            XCTAssertEqual(payment.quantity, 99)

            let queue = StubPaymentQueue()
            let originalTransaction = StubPaymentTransaction(transactionIdentifier: "ORIGINAL_TRANSACTION_001", transactionState: .purchased, payment: payment)
            let transaction = StubPaymentTransaction(transactionIdentifier: "TRANSACTION_001", transactionState: .purchased, original: originalTransaction, payment: payment)
            handler(queue, .success(transaction))

            expectation1.fulfill()
        })

        let expectation2 = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(
            productIdentifier: "PRODUCT_001",
            paymentBuildWith: { (product, completion) in
                let payment = SKMutablePayment(product: product)
                payment.quantity = 99
                completion(.success(payment))
            },
            handler: { (result) in
                switch result {
                case .success(let state):
                    XCTAssertEqual(state.state, .purchased)
                    XCTAssertEqual(state.transaction.transactionIdentifier, "TRANSACTION_001")
                    XCTAssertEqual(state.transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
                case .failure:
                    XCTFail()
                }
                expectation2.fulfill()
            })
        wait(for: [expectation1, expectation2], timeout: 1)
    }

    func testPurchaseWithPaymentBuilderWhereFailureBuildPayment() {
        let product = StubProduct(productIdentifier: "PRODUCT_001")
        let productProvider = StubProductProvider(result: .success([product]))
        let paymentProvider = StubPaymentProvider()

        let expectation = self.expectation()
        let iap = InAppPurchase(product: productProvider, payment: paymentProvider)
        iap.purchase(
            productIdentifier: "PRODUCT_001",
            paymentBuildWith: { (product, handler) in
                handler(.failure(InAppPurchase.Error(code: .paymentNotAllowed, transaction: nil)))
            },
            handler: { (result) in
                switch result {
                case .failure(let error):
                    switch error.code {
                    case .with(let error):
                        let error = error as? InAppPurchase.Error
                        XCTAssertNotNil(error)
                        XCTAssertEqual(error!.code, .paymentNotAllowed)
                    default:
                        XCTFail()
                    }
                default:
                    XCTFail()
                }
                expectation.fulfill()
            })
        wait(for: [expectation], timeout: 1)
    }

    func testConvertWhereSuccess() {
        let expectation = self.expectation()
        let purchaseHandler: InAppPurchase.PurchaseHandler = { result in
            switch result {
            case .success(let state):
                XCTAssertEqual(state.state, .purchased)
                XCTAssertEqual(state.transaction.transactionIdentifier, "TRANSACTION_001")
                XCTAssertEqual(state.transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
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
                if case .storeTrouble = error.code {
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
        fallbackHandler(StubPaymentQueue(), .failure(.init(code: .storeTrouble, transaction: nil)))
        wait(for: [expectation], timeout: 1)
    }

    func testHandleWherePurchasing() {
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .purchasing,
            payment: payment
        )

        InAppPurchase.handle(transaction: transaction, handler: { _ in
            XCTFail()
        })
    }

    func testHandleWherePurchased() {
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
        InAppPurchase.handle(transaction: transaction, handler: { result in
            switch result {
            case .success(let state):
                XCTAssertEqual(state.state, .purchased)
                XCTAssertEqual(state.transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
                XCTAssertEqual(state.transaction.originalTransactionIdentifier, "ORIGINAL_TRANSACTION_001")
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testHandleWhereRestored() {
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            payment: payment
        )

        let expectation = self.expectation()
        InAppPurchase.handle(transaction: transaction, handler: { result in
            switch result {
            case .success(let state):
                XCTAssertEqual(state.state, .restored)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }

    func testHandleWhereDeferred() {
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .deferred,
            payment: payment
        )

        let expectation1 = self.expectation()
        InAppPurchase.handle(transaction: transaction, handler: { result in
            switch result {
            case .success(let state):
                XCTAssertEqual(state.state, .deferred)
            case .failure:
                XCTFail()
            }
            expectation1.fulfill()
        })
        wait(for: [expectation1], timeout: 1)
    }

    func testHandleWhereFailed() {

        let error = NSError(domain: "test", code: 500, userInfo: nil)
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .failed,
            payment: payment,
            error: error
        )

        let expectation = self.expectation()
        InAppPurchase.handle(transaction: transaction, handler: { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                if case let .with(err) = error.code {
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

    func testRefreshReceipt() {
        let receiptRefreshProvider = StubReceiptRefreshProvider(result: .success(()))
        let expectation = self.expectation()
        let iap = InAppPurchase(receiptRefresh: receiptRefreshProvider)
        iap.refreshReceipt(handler: { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure:
                XCTFail()
            }
            expectation.fulfill()

        })
        wait(for: [expectation], timeout: 1)
    }

    func testRefreshReceiptWhereFailure() {
        let receiptRefreshProvider = StubReceiptRefreshProvider(result: .failure(.init(code: .storeTrouble, transaction: nil)))
        let expectation = self.expectation()
        let iap = InAppPurchase(receiptRefresh: receiptRefreshProvider)
        iap.refreshReceipt(handler: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                let expression: Bool
                if case .storeTrouble = error.code {
                    expression = true
                } else {
                    expression = false
                }
                XCTAssertTrue(expression)
            }
            expectation.fulfill()

        })
        wait(for: [expectation], timeout: 1)
    }

    func testFinishTransaction() {
        let expectation = self.expectation()
        let payment = StubPayment(productIdentifier: "PRODUCT_001")
        let transaction = StubPaymentTransaction(
            transactionIdentifier: "TRANSACTION_001",
            transactionState: .restored,
            original: nil,
            payment: payment,
            error: nil
        )
        let paymentProvider = StubPaymentProvider(finishTransactionHandler: { transaction in
            XCTAssertEqual(transaction.transactionIdentifier, "TRANSACTION_001")
            expectation.fulfill()
        })

        let iap = InAppPurchase(payment: paymentProvider)
        iap.finish(transaction: .init(transaction))
        wait(for: [expectation], timeout: 1)
    }

    func testTransactions() {
        let paymentProvider = StubPaymentProvider(transactions: [
            .init(StubPaymentTransaction(
                transactionIdentifier: "TRANSACTION_001",
                transactionState: .purchased
            )),
            .init(StubPaymentTransaction(
                transactionIdentifier: "TRANSACTION_002",
                transactionState: .deferred
            ))
        ])
        let iap = InAppPurchase(payment: paymentProvider)
        let transactions = iap.transactions

        XCTAssertEqual(transactions.count, 2)
        XCTAssertEqual(transactions[0].transactionIdentifier, "TRANSACTION_001")
        XCTAssertEqual(transactions[0].state, .purchased)
        XCTAssertEqual(transactions[1].transactionIdentifier, "TRANSACTION_002")
        XCTAssertEqual(transactions[1].state, .deferred)
    }
}

extension XCTestCase {
    func expectation(function: String = #function, line: Int = #line) -> XCTestExpectation {
        return self.expectation(description: "\(function) L\(line)")
    }
}
