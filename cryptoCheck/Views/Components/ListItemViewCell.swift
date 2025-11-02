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

    var cancellable: AnyCancellable?

    private let inset: CGFloat = 15

    private var lastPrice: Double = 0.0
    private var title: String?

    // MARK: - UI Items
    private lazy var container = UIView()
    private lazy var mainStackView = UIStackView()
    private lazy var titleView = UIView()

    private lazy var currencyValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var timestamp: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var indicatorIcon: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "slash.circle"))
        image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        image.tintColor = .unchanged
        return image
    }()

    private lazy var ammountValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var percentageValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    private lazy var currentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.text = "Current value:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var ammountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.text = "Ammount changed:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .cardText
        label.text = "Change percentage:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
        restartFields()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(currencyValueLabel)
        titleView.addSubview(indicatorIcon)
        titleView.addSubview(timestamp)
        container.addSubview(titleView)

        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = inset
        mainStackView.layoutMargins = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.backgroundColor = .cardBackground
        mainStackView.layer.cornerRadius = 12
        mainStackView.layer.masksToBounds = true

        mainStackView.addArrangedSubview(titleView)
        container.addSubview(mainStackView)

        setupLine(for: currentLabel, and: currentValueLabel)
        setupLine(for: ammountLabel, and: ammountValueLabel)
        setupLine(for: percentageLabel, and: percentageValueLabel)

        contentView.addSubview(container)
        setupConstraints()
    }

    private func setupLine(for title: UIView, and value: UIView) {
        let lineStack = UIStackView()
        let lineContainer = UIView()
        value.contentMode = .scaleAspectFit
        lineStack.axis = .horizontal
        lineStack.addArrangedSubview(title)
        lineStack.addArrangedSubview(value)
        lineStack.distribution = .fillEqually
        lineContainer.addSubview(lineStack)

        lineStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mainStackView.addArrangedSubview(lineContainer)
    }

    private func setupConstraints() {
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
        }

        mainStackView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }

        currencyValueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        indicatorIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(currencyValueLabel.snp.trailing).offset(10)
            make.bottom.equalToSuperview()
        }

        timestamp.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        cancellable = nil
        restartFields()
    }

    private func restartFields() {
        self.timestamp.text = "--"
        self.currencyValueLabel.text = "Loading Items...."
        self.ammountValueLabel.text = "--"
        self.percentageValueLabel.text = "--"
        self.indicatorIcon.image = UIImage(systemName: "slash.circle")
    }

    func configure(with price: PriceModel?) {
        guard let price else { return }
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

            self.timestamp.text = formatter.string(from: date)
            self.currencyValueLabel.text = price.symbol

            self.currentValueLabel.text = if let current = currentValue {
                numberFormatter.string(from: NSNumber(value: current))
            } else {
                "--"
            }

            self.ammountValueLabel.text = if let change = priceChange {
                numberFormatter.string(from: NSNumber(value: change))
            } else {
                "--"
            }
            self.percentageValueLabel.text = Double(price.priceChangePercent)?.formatted(.percent) ?? 0.00.formatted(.percent)

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
