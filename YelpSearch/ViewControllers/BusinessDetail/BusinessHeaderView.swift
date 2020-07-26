//
//  BusinessHeaderView.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

class BusinessHeaderView: UIView {

    private(set) lazy var imageView = buildImageView()
    private(set) lazy var gradiantOverlay = buildGradiantOverlay()
    private(set) lazy var labelsStackView = buildStackView()
    let gradientLayer = CAGradientLayer()
    let nameLabel = UILabel(textStyle: .title1, color: .white, numberOfLine: 2)
    let addressLabel = UILabel(textStyle: .title3, color: .white, numberOfLine: 3)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }

    private func buildImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private func buildGradiantOverlay() -> UIView {
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.locations = [0, 1]

        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.layer.insertSublayer(gradientLayer, at: 0)
        return overlayView
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

extension BusinessHeaderView: ProgrammaticUI {
    func configureSubviews() {
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(addressLabel)

        gradiantOverlay.addSubview(labelsStackView)

        addSubview(imageView)
        addSubview(gradiantOverlay)
    }

    func setupConstraints() {
        imageView.constraintToSuperviewEdges()
        gradiantOverlay.constraintToSuperviewEdges()
        labelsStackView.constraintToSuperviewEdges(
            except: .top,
            withInsets: .init(top: 0, left: Spacing.s4, bottom: Spacing.s4, right: Spacing.s4)
        )
    }
}
