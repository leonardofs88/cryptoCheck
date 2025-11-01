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
import Combine

protocol MainViewControllerProtocol<T>: UITableViewDataSource, UITableViewDelegate {
    // swiftlint:disable:next type_name
    associatedtype T = Codable

    var coordinator: (any CoordinatorProtocol)? { get }
    var viewModel: any MainViewModelProtocol<T> { get }
}

class MainViewController<T: Codable>: UIViewController, MainViewControllerProtocol {

    private(set) weak var coordinator: (any CoordinatorProtocol)?

    @LazyInjected(\.mainViewModel) private(set) var viewModel

    private lazy var tableView = UITableView()

    private var dataSource: [String: PriceModel] = [:] {
        didSet {
            tableView.reloadData()
        }
    }

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "E.g.: BTCUSDT"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let addButton: UIButton = {
        let button = UIButton(configuration: .borderedProminent())
        button.setTitle("Add", for: .normal)
        button.setTitle("Reached max items", for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var items: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.items.count < 5 {
                    self.viewModel.sendMessage(.subscribe, for: self.items)
                    self.addButton.isEnabled = true
                } else {
                    self.addButton.isEnabled = false
                }
            }
        }
    }

    private lazy var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mainBackground
        navigationItem.rightBarButtonItem = editButtonItem

        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !items.isEmpty {
            viewModel.startObsevingSocket()
            viewModel.sendMessage(.subscribe, for: items)
        }
        listenToChanges()
    }

    private func listenToChanges() {
        viewModel.sourcePublisher
            .receive(on: DispatchQueue.main)
            .compactMap({ $0 })
            .sink { [weak self] fetchedItem in
                guard let self, !isEditing else { return }
                self.dataSource[fetchedItem.symbol] = fetchedItem
            }.store(in: &cancellables)
    }

    func setCoordinator(_ coordinator: any CoordinatorProtocol) {
        self.coordinator = coordinator
    }

    private func setupTableView() {
        view.addSubview(textField)
        view.addSubview(addButton)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(ListItemViewCell.self, forCellReuseIdentifier: "ListItemViewCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        setupConstraints()
    }

    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(15)
        }

        addButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(15)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        setupActions()
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    @objc private func addButtonTapped() {
        guard let text = textField.text, !text.isEmpty, !items.contains(where: { $0 == text }) else { return }
        items.append(text)
        textField.text = ""
        textField.resignFirstResponder()
//        tableView.beginUpdates()
//        tableView.insertRows(at: [IndexPath.init(row: self.dataSource.count-1, section: 0)], with: .automatic)
//        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.sendMessage(.unsubscribe, for: [items[indexPath.row]])
            dataSource.removeValue(forKey: items[indexPath.row])
            items.remove(at: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListItemViewCell",
            for: indexPath
        ) as? ListItemViewCell else {
            return ListItemViewCell()
        }

        cell.configure(with: dataSource[items[indexPath.row]])

        return cell
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.sendMessage(.unsubscribe, for: items)
        coordinator?.showDetailsView(for: items[indexPath.row])
    }
}
