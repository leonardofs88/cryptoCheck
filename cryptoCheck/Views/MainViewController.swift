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

class MainViewController: UIViewController {

    @WeakLazyInjected(\.coordinator) private var coordinator
    @LazyInjected(\.mainViewModel) private var viewModel

    private lazy var tableView = UITableView()

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "E.g.: BTCUSDT"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var items: [String] = [] {
        didSet {
            if items.count < 5 {
                viewModel.sentMessage(for: items)
                addButton.titleLabel?.text = "Add"
                addButton.isEnabled = true
            } else {
                addButton.titleLabel?.text = "Reached max items"
                addButton.isEnabled = false
            }
        }
    }

    private var selectedItems: [String] = []
    private var fetchedSource: [String: PriceModel] = [:]

    private lazy var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mainBackground
        navigationItem.rightBarButtonItem = editButtonItem
        setupTableView()
        listenToItems()
    }

    private func listenToItems() {
        viewModel.sourcePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self, !isEditing else { return }
                DispatchQueue.main.async {
                    items.forEach { (key, value) in self.fetchedSource[key] = value }
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }

    private func setupTableView() {
        view.addSubview(textField)
        view.addSubview(addButton)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(ListItemViewCell.self, forCellReuseIdentifier: "ListItemViewCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        setupConstraints()
    }

    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(15)
        }

        addButton.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.equalTo(textField.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom)
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
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListItemViewCell",
            for: indexPath
        ) as? ListItemViewCell else {
            return ListItemViewCell()
        }

        cell.configure(with: fetchedSource[items[indexPath.row]])
        return cell
    }
}
