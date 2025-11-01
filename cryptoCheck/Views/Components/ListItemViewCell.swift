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

    private var didSetupConstraints = false
    private let inset: CGFloat = 15
    private let container = UIView()
    private let mainStackView = UIStackView()
    private let titleView = UIView()

    private var lastPrice: Double = 0.0
    private var title: String?

    private let currencyValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timestamp: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let indicatorIcon: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "slash.circle"))
        image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        return image
    }()

    private let ammountValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let percentageValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ammountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Ammount:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Percentage:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
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
        mainStackView.backgroundColor = .white
        mainStackView.layer.cornerRadius = 12
        mainStackView.layer.masksToBounds = true

        mainStackView.addArrangedSubview(titleView)
        container.addSubview(mainStackView)

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
            make.leading.equalTo(indicatorIcon.snp.trailing).offset(10)
            make.bottom.equalToSuperview()
        }
    }

    func configure(with price: PriceModel?) {
        guard let price else { return }
        DispatchQueue.main.async {
            let date = Date.now
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss, d MM y"

            let priceChange = Double(price.priceChange)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale.current
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 6

            self.timestamp.text = formatter.string(from: date)
            self.currencyValueLabel.text = price.symbol
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
                    .gray
                } else {
                    currentPrice > self.lastPrice ? .green : .red
                }

                print("========Check price========")
                print("Current price:", self.ammountValueLabel.text)
                print("Last price:", self.lastPrice)
                print("Icon:", icon)
                print("Color:", color.name)
                print("Date:", formatter.string(from: date))
                print("===========================")

                self.indicatorIcon.image = UIImage(systemName: icon)
                self.indicatorIcon.tintColor = color
                self.lastPrice = currentPrice
            }

        }
    }

    deinit {
        print("cell deinited")
    }
}

extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.darkGray: return "darkGray"
        case UIColor.lightGray: return "lightGray"
        case UIColor.white: return "white"
        case UIColor.gray: return "gray"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.blue: return "blue"
        case UIColor.cyan: return "cyan"
        case UIColor.yellow: return "yellow"
        case UIColor.magenta: return "magenta"
        case UIColor.orange: return "orange"
        case UIColor.purple: return "purple"
        case UIColor.brown: return "brown"
        default: return nil
        }
    }
}
