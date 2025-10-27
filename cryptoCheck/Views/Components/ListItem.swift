//
//  ListItem.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 27/10/2025.
//

import UIKit
import SnapKit

class ListItem: UITableViewCell {
    private var didSetupConstraints = false
    private let inset = 15

    let containerView = UIStackView()

    private let currencyValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ammountValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let percentageValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Currency:"
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
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        containerView.axis = .vertical
        containerView.distribution = .fillProportionally
        containerView.spacing = 10
        self.addSubview(containerView)

        setupLine(for: currencyLabel, and: currencyValueLabel)
        setupLine(for: ammountLabel, and: ammountValueLabel)
        setupLine(for: percentageLabel, and: ammountValueLabel)

        setupConstraints()
    }

    private func setupLine(for title: UILabel, and value: UILabel) {
        let lineStack = UIStackView()
        let lineContainer = UIView()
        lineStack.axis = .horizontal
        value.textAlignment = .right
        lineStack.addArrangedSubview(title)
        lineStack.addArrangedSubview(value)
        lineContainer.addSubview(lineStack)
        lineStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.addArrangedSubview(lineContainer)
    }

    private func setupConstraints() {
        if !didSetupConstraints {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(inset)
            }
        }
    }

    func configureContent(with price: PriceModel) {
        currencyValueLabel.text = price.eventType
        ammountValueLabel.text = price.priceChange
        percentageValueLabel.text = price.priceChangePercent
//        layoutIfNeeded()
    }
}
