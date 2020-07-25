//
//  ReuseIdentifiable.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReuseIdentifiable {}
extension UICollectionViewCell: ReuseIdentifiable {}
extension UITableViewHeaderFooterView: ReuseIdentifiable {}
