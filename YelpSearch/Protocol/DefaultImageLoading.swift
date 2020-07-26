//
//  DefaultImageLoading.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

protocol DefaultImageLoading {
    var defaultImage: UIImage? { get }
}

extension DefaultImageLoading {
    var defaultImage: UIImage? {
        return UIImage(named: "default_image")
    }
}
