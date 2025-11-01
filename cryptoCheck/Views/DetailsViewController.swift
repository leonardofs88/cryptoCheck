//
//  DetailsViewController.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import Factory
import UIKit
import SnapKit
import Combine

class DetailsViewController: UIViewController {

    @Injected(\.mainViewModel) private var mainViewModel

    private weak var coordinator: CoordinatorProtocol?
    private var symbol: String?
    private var price: PriceModel? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    private var cancellable: AnyCancellable?

    // MARK: - UI Components

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let nameDetail = DetailItem()
    private let lastPriceDetail = DetailItem()
    private let priceChangeDetail = DetailItem()
    private let priceChangePercentDetail = DetailItem()
    private let openPriceDetail = DetailItem()
    private let highPriceDetail = DetailItem()
    private let lowPriceDetail = DetailItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = price?.symbol.uppercased()
        view.backgroundColor = .mainBackground
        setupViews()
        listenToChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainViewModel.startObsevingSocket()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let symbol = price?.symbol {
            mainViewModel.sendMessage(.unsubscribe, for: [symbol])
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let symbol {
            mainViewModel.sendMessage(.subscribe, for: [symbol])
        }
    }

    func setCoordinator(_ coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func setData(symbol: String) {
        self.symbol = symbol
    }

    private func listenToChanges() {
        cancellable = mainViewModel.sourcePublisher
            .receive(on: DispatchQueue.main)
            .filter({
                $0.symbol == self.symbol
            })
            .sink { [weak self] fetchedItem in
                guard let self, !isEditing else { return }
                DispatchQueue.main.async {
                    self.price = fetchedItem
                }
            }
    }

    private func updateViews() {
        nameDetail.configure(title: "Symbol", value: price?.symbol ?? "Not available")

        lastPriceDetail.configure(
            title: "Last Price",
            value: Double(price?.lastPrice ?? "")?.formatted(.currency(code: "USD")) ?? "Not available"
        )

        priceChangeDetail.configure(
            title: "Ammount changed",
            value: Double(price?.priceChange ?? "")?.formatted(.currency(code: "USD")) ?? "Not available"
        )

        priceChangePercentDetail.configure(
            title: "Ammount changed percent",
            value: Double(price?.priceChangePercent ?? "")?.formatted(.percent) ?? "Not available"
        )

        openPriceDetail.configure(
            title: "Open price",
            value: Double(
                price?.openPrice ?? ""
            )?.formatted(.currency(code: "USD")) ?? "Not available"
        )

        highPriceDetail.configure(
            title: "Highest price",
            value: Double(
                price?.highPrice ?? ""
            )?.formatted(.currency(code: "USD")) ?? "Not available"
        )

        lowPriceDetail.configure(
            title: "Lowest price",
            value: Double(price?.lowPrice ?? "")?.formatted(.currency(code: "USD")) ?? "Not available"
        )
    }

    private func setupViews() {

        self.view.addSubview(containerStackView)

        containerStackView.addArrangedSubview(nameDetail)

        containerStackView.addArrangedSubview(lastPriceDetail)

        containerStackView.addArrangedSubview(priceChangeDetail)

        containerStackView.addArrangedSubview(priceChangePercentDetail)

        containerStackView.addArrangedSubview(openPriceDetail)

        containerStackView.addArrangedSubview(highPriceDetail)

        containerStackView.addArrangedSubview(lowPriceDetail)

        containerStackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        updateViews()
    }
}

class DetailItem: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    private let mainStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(valueLabel)
        addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        setupViews()
        layoutIfNeeded()
    }
}
