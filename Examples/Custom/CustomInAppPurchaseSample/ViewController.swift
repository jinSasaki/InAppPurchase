//
//  ViewController.swift
//  CustomInAppPurchaseSample
//
//  Created by Jin Sasaki on 2021/08/06.
//

import UIKit
import InAppPurchase

enum Constant {
    enum Product {
        static let coin = "jp.sasakky.coin"
        static let full = "jp.sasakky.full"
        static let subscription = "jp.sasakky.subscription.weekly"
    }
}

final class ViewController: UIViewController {

    var transactions: [PaymentTransaction] = []

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.reloadTransactions()
        }
    }

    @IBAction func tapPurchaseCoin() {
        let id = Constant.Product.coin
        InAppPurchase.custom.purchase(productIdentifier: id) { [weak self] result in
            self?.handle(result: result)
        }
    }

    @IBAction func tapPurchaseFull() {
        let id = Constant.Product.full
        InAppPurchase.custom.purchase(productIdentifier: id) { [weak self] result in
            self?.handle(result: result)
        }
    }

    @IBAction func tapPurchaseSubscription() {
        let id = Constant.Product.subscription
        InAppPurchase.custom.purchase(productIdentifier: id) { [weak self] result in
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
            self.reloadTransactions()
        case .failure(let error):
            print(error)
        }
    }

    private func reloadTransactions() {
        self.transactions = InAppPurchase.custom.transactions
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "default")
        let transaction = transactions[indexPath.row]
        cell.textLabel?.text = "\(transaction.productIdentifier) \(transaction.transactionIdentifier ?? "-")"
        cell.detailTextLabel?.text = "\(transaction.state)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = transactions[indexPath.row]
        let alert = UIAlertController(title: "Finish transaction?", message: transaction.transactionIdentifier, preferredStyle: .alert)
        alert.addAction(.init(title: "Finish", style: .default, handler: { [weak self] _ in
            InAppPurchase.custom.finish(transaction: transaction)
            self?.reloadTransactions()
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
