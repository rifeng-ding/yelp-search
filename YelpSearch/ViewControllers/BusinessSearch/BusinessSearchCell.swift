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

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = CornerRadius.standard
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.separator.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CornerRadius.standard).cgPath
    }

    override func prepareForReuse() {
        imageView.image = nil
    }
}
