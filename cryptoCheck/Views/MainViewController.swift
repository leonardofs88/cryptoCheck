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

protocol MainViewControllerProtocol<T>: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    // swiftlint:disable:next type_name
    associatedtype T = Codable

    var coordinator: (any CoordinatorProtocol)? { get }
    var viewModel: any MainViewModelProtocol<T> { get }

    func setCoordinator(_ coordinator: any CoordinatorProtocol)
}

class MainViewController<T: Codable>: UIViewController, MainViewControllerProtocol {

    @LazyInjected(\.mainViewModel) private(set) var viewModel

    // MARK: - UI ITEMS
    private lazy var tableView = UITableView()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 25, weight: .semibold)
        field.textColor = .appText
        field.delegate = self
        field.placeholder = "E.g.: BTCUSDT"
        field.backgroundColor = .clear
        field.tintColor = .appText
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        return field
    }()

    private lazy var dividerView: UIView = {
        var view = UIView(frame: .zero)
        view.backgroundColor = .cardBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(configuration: .borderedProminent())
        button.setTitle("Add", for: .normal)
        button.setTitle("Reached max items", for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.configuration?.background.backgroundColor = .cardBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - PROPERTIES

    private(set) weak var coordinator: (any CoordinatorProtocol)?

    private var items: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                self.addButton.isEnabled = self.items.count != 5
                self.viewModel.sendMessage(.subscribe, for: self.items)
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .mainBackground
        navigationItem.rightBarButtonItem = editButtonItem

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissMissKeyboard))
        view.addGestureRecognizer(tap)

        setupTableView()
    }

    @objc func dissMissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !items.isEmpty {
            viewModel.sendMessage(.subscribe, for: items)
            tableView.reloadData()
        }
    }

    // MARK: - Public functions

    func setCoordinator(_ coordinator: any CoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - Private functions

    private func setupTableView() {
        view.addSubview(textField)
        view.addSubview(dividerView)
        view.addSubview(addButton)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(ListItemViewCell.self, forCellReuseIdentifier: "ListItemViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
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

        dividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(textField.snp.bottom).offset(5)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(15)
        }

        addButton.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(15)
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
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath.init(row: items.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }

    // MARK: - UITableViewDelegate functions

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ListItemViewCell",
                for: indexPath
            ) as? ListItemViewCell else {
                return
            }
            DispatchQueue.main.async {
                cell.cancellable?.cancel()
                self.viewModel.sendMessage(.unsubscribe, for: [self.items[indexPath.row]])
                self.items.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
            }
        }
    }

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

        cell.setupCell(items[indexPath.row])
        cell.cancellable?.cancel()

        cell.cancellable = viewModel.sourcePublisher
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] item in
                guard let self, !isEditing, items.indices.contains(indexPath.row) else { return false }
                return item.symbol == cell.title
            })
            .sink(receiveValue: { value in
                cell.configure(with: value)
            })

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListItemViewCell else { return }

        if cell.selectableCell {
            viewModel.sendMessage(.unsubscribe, for: items)
            coordinator?.showDetailsView(for: items[indexPath.row])
        }
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == self.textField {
            if string == "" {
                textField.deleteBackward()
            } else {
                textField.insertText(string.uppercased())
            }
            return false
        }

        return true
    }
}
