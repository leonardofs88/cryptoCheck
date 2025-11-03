//
//  ListItemViewCell.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import UIKit
import SnapKit
import Factory
import Combine

class ListItemViewCell: UITableViewCell {

    lazy var cancellables = Set<AnyCancellable>()

    private let inset: CGFloat = 15

    private var lastPrice: Double = 0.0
    private var title: String?
    private var timer: Timer?

    // MARK: - UI Items

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        stackView.backgroundColor = .cardBackground
        stackView.layer.cornerRadius = 12
        return stackView
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return stackView
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        stackView.spacing = 5
        stackView.layer.masksToBounds = true
        return stackView
    }()

    private lazy var currencyValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.text = "Loading data..."
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.text = "--"
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var indicatorIcon: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "slash.circle"))
        image.contentMode = .scaleAspectFit
        image.tintColor = .unchanged
        image.snp.makeConstraints { make in
            make.width.equalTo(45)
        }
        return image
    }()

    private lazy var currentPriceDetail = DetailItemStackView()
    private lazy var ammountDetail = DetailItemStackView()
    private lazy var percentageDetail = DetailItemStackView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private functions
    private func setupViews() {
        resetViews()
        infoStackView.addArrangedSubview(currentPriceDetail)
        infoStackView.addArrangedSubview(ammountDetail)
        infoStackView.addArrangedSubview(percentageDetail)

        titleStackView.addArrangedSubview(currencyValueLabel)
        titleStackView.addArrangedSubview(timestampLabel)

        contentStackView.addArrangedSubview(titleStackView)
        contentStackView.addArrangedSubview(infoStackView)

        mainStackView.addArrangedSubview(indicatorIcon)
        mainStackView.addArrangedSubview(contentStackView)

        contentView.addSubview(mainStackView)
        setupConstraints()
    }

    private func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }

    private func startTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
                self?.showError()
            })
        }
    }

    private func showError() {
        timer?.invalidate()
        timer = nil
        indicatorIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        indicatorIcon.tintColor = .negative
        currencyValueLabel.text = "Error: \(title ?? "")"
        timestampLabel.text = "No data for the symbol. Check for spell mistakes and try again."
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    private func resetViews() {
        currencyValueLabel.text = "Loading data..."
        currentPriceDetail.configure(title: "Current price", value: "--")
        ammountDetail.configure(title: "Change ammount", value: "--")
        percentageDetail.configure(title: "Change percentage", value: "--")
        indicatorIcon.image = UIImage(systemName: "slash.circle")
        indicatorIcon.tintColor = .unchanged
    }

    func setupCell(_ title: String) {
        self.title = title
        self.currencyValueLabel.text = "Loading \(title)..."
        self.startTimer()
    }

    func configure(with price: PriceModel?) {
        guard let price else { return }
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        DispatchQueue.main.async {
            let date = Date.now
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss, d MMM y"

            let priceChange = Double(price.priceChange)
            let currentValue = Double(price.lastPrice)

            let numberFormatter = NumberFormatter()

            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale.current
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 6

            self.timestampLabel.text = formatter.string(from: date)
            self.currencyValueLabel.text = price.symbol

            if let current = currentValue, let formatted = numberFormatter.string(from: NSNumber(value: current)) {
                self.currentPriceDetail.configure(title: "Current price", value: formatted)
            }

            if let change = priceChange, let formatted = numberFormatter.string(from: NSNumber(value: change)) {
                self.ammountDetail.configure(title: "Change ammount", value: formatted)
            }

            if let formatted = Double(price.priceChangePercent)?.formatted(.percent) {
                self.percentageDetail.configure(title: "Change percentage", value: formatted)
            }

            if let currentPrice = priceChange {
                let icon = if currentPrice == self.lastPrice {
                    "slash.circle"
                } else {
                    currentPrice > self.lastPrice ? "chevron.up.2" : "chevron.down.2"
                }

                let color: UIColor = if currentPrice == self.lastPrice {
                    .unchanged
                } else {
                    currentPrice > self.lastPrice ? .positive : .negative
                }

                self.indicatorIcon.image = UIImage(systemName: icon)
                self.indicatorIcon.tintColor = color
                self.lastPrice = currentPrice
            }
        }
    }
}
