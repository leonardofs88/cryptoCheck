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

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = inset
        stackView.layoutMargins = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .cardBackground
        stackView.layer.cornerRadius = 12
        stackView.layer.masksToBounds = true
        return stackView
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        stackView.layer.masksToBounds = true
        return stackView
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.masksToBounds = true
        return stackView
    }()

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
        titleStackView.addArrangedSubview(currencyValueLabel)
        titleStackView.addArrangedSubview(indicatorIcon)
        titleStackView.addArrangedSubview(timestamp)

        mainStackView.addArrangedSubview(titleStackView)

        setupLine(for: currentLabel, and: currentValueLabel)
        setupLine(for: ammountLabel, and: ammountValueLabel)
        setupLine(for: percentageLabel, and: percentageValueLabel)

        mainStackView.addArrangedSubview(infoStackView)

        contentView.addSubview(mainStackView)
        setupConstraints()
    }

    private func setupLine(for title: UIView, and value: UIView) {
        let lineStack = UIStackView()
        value.contentMode = .scaleAspectFit
        lineStack.axis = .horizontal
        lineStack.addArrangedSubview(title)
        lineStack.addArrangedSubview(value)
        lineStack.distribution = .fillEqually

        infoStackView.addArrangedSubview(lineStack)
    }

    private func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
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
        self.currentValueLabel.text = "--"
        self.ammountValueLabel.text = "--"
        self.percentageValueLabel.text = "--"
        self.indicatorIcon.image = UIImage(systemName: "slash.circle")
    }

    func configure(with price: PriceModel?) {
        guard let price else { return }
        DispatchQueue.main.async {
            self.infoStackView.isHidden = false
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
