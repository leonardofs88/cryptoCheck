//
//  MainViewController.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Foundation
import UIKit
import SnapKit
import Factory

class MainViewController: UIViewController {

    @WeakLazyInjected(\.coordinator) private var coordinator

    private let tableView = UITableView()

    private let source: [PriceModel] = [PriceModel(
        eventType: "trade",
        eventTime: Date(),
        symbol: "Symbol",
        priceChange: "0002.22",
        priceChangePercent: "002220.246",
        weightedAvgPrice: "29941.22",
        firstTradePrice: "900023.2",
        lastPrice: "09934.22",
        lastQuantity: "000232.12",
        bestBidPrice: "0002392.223",
        bestBidQuantity: "00302.3322",
        bestAskPrice: "200032.2333",
        bestAskQuantity: "2399921.22",
        openPrice: "299312.23",
        highPrice: "2939212.22",
        lowPrice: "00645893.332",
        baseVolume: "299932.122",
        quoteVolume: "22231.2332",
        openTime: Date(),
        closeTime: Date(),
        firstTradeId: 20021,
        lastTradeId: 23991,
        tradeCount: 221
    ), PriceModel(
        eventType: "trade",
        eventTime: Date(),
        symbol: "Symbol",
        priceChange: "0002.22",
        priceChangePercent: "002220.246",
        weightedAvgPrice: "29941.22",
        firstTradePrice: "900023.2",
        lastPrice: "09934.22",
        lastQuantity: "000232.12",
        bestBidPrice: "0002392.223",
        bestBidQuantity: "00302.3322",
        bestAskPrice: "200032.2333",
        bestAskQuantity: "2399921.22",
        openPrice: "299312.23",
        highPrice: "2939212.22",
        lowPrice: "00645893.332",
        baseVolume: "299932.122",
        quoteVolume: "22231.2332",
        openTime: Date(),
        closeTime: Date(),
        firstTradeId: 20021,
        lastTradeId: 23991,
        tradeCount: 221
    )]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mainBackground
        setupNavigationBar()
        setupTableView()
    }

    func setupNavigationBar() {
        self.title = "Currencies List"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.register(ListItemViewCell.self, forCellReuseIdentifier: "ListItem")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        source.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListItem", for: indexPath) as? ListItemViewCell else {
            return ListItemViewCell()
        }

        cell.configureContent(with: source[indexPath.row])
        return cell
    }
}
