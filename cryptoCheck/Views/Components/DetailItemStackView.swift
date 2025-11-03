//
//  DetailItemStackView.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 03/11/2025.
//

import UIKit
import SnapKit

class DetailItemStackView: UIStackView {
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
        label.text = "--"
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        axis = .horizontal
        distribution = .fillEqually
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addArrangedSubview(titleLabel)
        addArrangedSubview(valueLabel)
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        setupViews()
        layoutIfNeeded()
    }
}
