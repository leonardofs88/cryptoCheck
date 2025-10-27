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
    @LazyInjected(\.mainViewModel) private var viewModel

    private let tableView = UITableView()

    private var items = ["btcusdt".uppercased(), "ethusdt".uppercased(), "adausdt".uppercased()]
    private var fetchedSource: [String: PriceModel] = [:]

    private lazy var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mainBackground
        setupNavigationBar()
        setupTableView()
        listenToItems()
    }

    private func listenToItems() {
        viewModel.sourcePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                DispatchQueue.main.async {
                    self?.fetchedSource.merge(items) { _, new in new }
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
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
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListItem", for: indexPath) as? ListItemViewCell else {
            return ListItemViewCell()
        }

//        cell.configureContent(with: source[indexPath.row])
        cell.configure(with: fetchedSource[items[indexPath.row]])
        return cell
    }
}

import Combine

protocol MainViewModelProtocol {
    associatedtype T = Codable
    var cancellables: Set<AnyCancellable> { get }
    var webSocketManager: any WebSocketManagerProtocol<T> { get }
    var sourcePublisher: PassthroughSubject<[String:PriceModel], Never> { get }

    func observeWebSocket()
}

class MainViewModel: MainViewModelProtocol {
    @Injected(\.webSocketManager) var webSocketManager

    private(set) var cancellables: Set<AnyCancellable> = []
    private(set) var sourcePublisher: PassthroughSubject<[String:PriceModel], Never> = .init()

    init() {
        observeWebSocket()
    }

    func observeWebSocket() {
        webSocketManager.setupWebSocket(for: .stream, portType: .primary)
        webSocketManager.sendMessage(with: WebSocketBody(method: .subscribe, params: ["btcusdt@ticker",
                                                                                      "ethusdt@ticker",
                                                                                      "adausdt@ticker"]))
        webSocketManager.managedItem
            .receive(on: RunLoop.main)
            .compactMap(\.?.data)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] item in
                print("::: ===>> RECEIVED ITEM:",item)
                self?.sourcePublisher.send([item.symbol:item])
            }
            .store(in: &cancellables)
    }
}

extension Container {
    var mainViewModel: Factory<any MainViewModelProtocol> {
        self { MainViewModel() }
    }
}
