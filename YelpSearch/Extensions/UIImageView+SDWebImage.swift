//
//  UIImageView+SDWebImage.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView {

    func loadImage(fromURL url: String?, defaultImage: UIImage? = nil) {
        guard let rawURL = url, let url = URL(string: rawURL) else {
            self.image = defaultImage
            return
        }

        sd_setImage(with: url) { [weak self] (image, error, _, _) in
            if image == nil || error != nil {
                self?.image = defaultImage
            }
        }
    }
}
