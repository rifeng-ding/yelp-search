//
//  BusinessReviewCell.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

class BusinessReviewCell: UITableViewCell {

    let userNameLabel = UILabel(textStyle: .headline, color: .label, numberOfLine: 1)
    let ratingLabel = UILabel(textStyle: .subheadline, color: .label, numberOfLine: 1)
    let commentLabel = UILabel(textStyle: .body, color: .secondaryLabel, numberOfLine: 0)
    private lazy var labelsStackView = buildStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = Spacing.s2
        return stackView
    }
}

extension BusinessReviewCell: ProgrammaticUI {
    func configureSubviews() {
        contentView.backgroundColor = .systemBackground
        labelsStackView.addArrangedSubview(userNameLabel)
        labelsStackView.addArrangedSubview(ratingLabel)
        labelsStackView.addArrangedSubview(commentLabel)
        contentView.addSubview(labelsStackView)
    }

    func setupConstraints() {
        labelsStackView.constraintToSuperviewLayoutMergin()
    }
}
