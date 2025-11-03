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

    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 6
        return numberFormatter
    }()

    // MARK: - UI Components

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
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

        navigationItem.title = price?.symbol.uppercased()

        nameDetail.configure(title: "Symbol", value: price?.symbol ?? "Loading data...")

        if let lastPrice = Double(price?.lastPrice ?? ""), let formated = numberFormatter.string(from: NSNumber(value: lastPrice)) {
            lastPriceDetail.configure(
                title: "Last Price",
                value: formated
            )
        }

        if let priceChange = Double(price?.priceChange ?? ""), let formated = numberFormatter.string(
            from: NSNumber(value: priceChange)
        ) {
            priceChangeDetail.configure(
                title: "Ammount changed",
                value: formated
            )
        }

        if let priceChangePercent = price?.priceChangePercent, let formatted = Double(priceChangePercent)?.formatted(.percent) {
            priceChangePercentDetail.configure(
                title: "Ammount changed percent",
                value:  formatted
            )
        }

        if let openPrice = Double(price?.openPrice ?? ""), let formated = numberFormatter.string(
            from: NSNumber(value: openPrice)
        ) {
            openPriceDetail.configure(
                title: "Open price",
                value: formated
            )
        }

        if let highPrice = Double(price?.highPrice ?? ""), let formated = numberFormatter.string(
            from: NSNumber(value: highPrice)
        ) {
            highPriceDetail.configure(
                title: "Highest price",
                value: formated
            )
        }

        if let lowPrice = Double(price?.lowPrice ?? ""), let formated = numberFormatter.string(
            from: NSNumber(value: lowPrice)
        ) {
            lowPriceDetail.configure(
                title: "Lowest price",
                value: formated
            )
        }
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(15)
        }

        containerStackView.backgroundColor = .cardBackground
        containerStackView.layer.cornerRadius = 12

        updateViews()
    }
}

class DetailItem: UIStackView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 3
        label.textColor = .cardText
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.textColor = .cardText
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        axis = .horizontal
        distribution = .fillEqually
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addArrangedSubview(titleLabel)
        addArrangedSubview(valueLabel)
        isHidden = false
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        setupViews()
        layoutIfNeeded()
    }
}
