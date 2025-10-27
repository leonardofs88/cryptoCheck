//
//  ListItemViewCell.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import UIKit
import SnapKit

class ListItemViewCell: UITableViewCell {
    private var didSetupConstraints = false
    private let inset = 15

    private let container = UIView()
    private let mainStackView = UIStackView()
    private let titleView = UIView()

    private let currencyValueLabel: UILabel = {
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
        container.addSubview(titleView)

        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 10
        mainStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.backgroundColor = .white
        mainStackView.layer.cornerRadius = 12
        mainStackView.layer.masksToBounds = true

        container.addSubview(mainStackView)
        mainStackView.addArrangedSubview(titleView)

        setupLine(for: ammountLabel, and: ammountValueLabel)
        setupLine(for: percentageLabel, and: percentageValueLabel)

        self.addSubview(container)
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
        if !didSetupConstraints {

            container.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(5)
                make.trailing.equalToSuperview().inset(5)
                make.bottom.equalToSuperview().inset(5)
                make.leading.equalToSuperview().inset(5)
            }

            mainStackView.snp.makeConstraints { make in
                make.size.equalToSuperview()
            }

            currencyValueLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(10)
                make.leading.equalToSuperview().inset(5)
                make.bottom.equalToSuperview().inset(10)
            }

            indicatorIcon.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(10)
                make.trailing.equalToSuperview().inset(10)
                make.bottom.equalToSuperview().inset(10)
            }
        }
    }

    func configureContent(with price: PriceModel) {
        currencyValueLabel.text = price.eventType
        ammountValueLabel.text = price.priceChange
        percentageValueLabel.text = price.priceChangePercent

        if let currentPrice = Double(price.priceChange),
           let lastPrice = Double(price.lastPrice) {
            indicatorIcon.image = UIImage(systemName: lastPrice > currentPrice ? "chevron.down.2" : "chevron.up.2")
            indicatorIcon.tintColor = lastPrice > currentPrice ? .red : .green
        }
    }
}
