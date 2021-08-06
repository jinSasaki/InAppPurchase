//
//  CustomPurchaseViewController.swift
//  InAppPurchaseSample
//
//  Created by Jin Sasaki on 2021/08/05.
//

import UIKit
import InAppPurchase

final class CustomPurchaseViewController: UIViewController {

    let iap = InAppPurchase(shouldCompleteImmediately: false)
    var responses: [PaymentResponse] = []

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }

    @IBAction func tapPurchaseCoin() {
        let id = Constant.Product.coin
        iap.purchase(productIdentifier: id) { [weak self] result in
            self?.handle(result: result)
        }
    }

    @IBAction func tapPurchaseFull() {
        let id = Constant.Product.full
        iap.purchase(productIdentifier: id) { [weak self] result in
            self?.handle(result: result)
        }
    }

    @IBAction func tapPurchaseSubscription() {
        let id = Constant.Product.subscription
        iap.purchase(productIdentifier: id) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<PaymentResponse, InAppPurchase.Error>) {
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
            self.responses.append(response)
        case .failure(let error):
            print(error)
        }
    }
}

extension CustomPurchaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "default")
        let response = responses[indexPath.row]
        cell.textLabel?.text = "\(response.transaction.productIdentifier) \(response.transaction.transactionIdentifier ?? "-")"
        cell.detailTextLabel?.text = "\(response.state)"
        return cell
    }
}

extension CustomPurchaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let response = responses[indexPath.row]
        let alert = UIAlertController(title: "Finish transaction?", message: response.transaction.transactionIdentifier, preferredStyle: .alert)
        alert.addAction(.init(title: "Finish", style: .default, handler: { [weak self] _ in
            self?.iap.finish(transaction: response.transaction)
            self?.responses.removeAll(where: { $0.transaction.transactionIdentifier == response.transaction.transactionIdentifier })
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
