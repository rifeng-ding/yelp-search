//
//  UILabel+Convenient.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

extension UILabel {

     convenience init(textStyle: UIFont.TextStyle, color: UIColor, numberOfLine: Int) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.preferredFont(forTextStyle: textStyle)
        self.textColor = color
        self.numberOfLines = numberOfLine
    }
}
