//
//  BusinessSearchCell.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

class BusinessSearchCell: UICollectionViewCell {

    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var infoLabel: UILabel!
    @IBOutlet private(set) weak var distanceLabel: UILabel!

    private var widthConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!

    var width: CGFloat {
        set {
            widthConstraint.constant = newValue
            imageViewHeightConstraint.constant = newValue
        }

        get {
            widthConstraint.constant
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 320)
        widthConstraint.isActive = true
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 320)
        imageViewHeightConstraint.isActive = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = CornerRadius.standard
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CornerRadius.standard).cgPath
    }
}
