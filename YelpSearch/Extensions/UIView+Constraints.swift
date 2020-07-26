//
//  UIView+Constraints.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

enum ViewEdge: Int {
    case leading
    case trailing
    case top
    case bottom
}

extension UIView {
    func constraintToSuperviewEdges(withInsets insets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            return
        }
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func constraintToSuperviewEdges(except edge: ViewEdge, withInsets insets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            return
        }
        // The order in the array has to follow corresponding enum's order in ViewEdge
        var constraints = [
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ]
        constraints.remove(at: edge.rawValue)
        NSLayoutConstraint.activate(constraints)
    }

    func constraintToSuperviewLayoutMergin(except edge: ViewEdge, withInsets insets: UIEdgeInsets = .zero) {
        guard let superview = superview else {
            return
        }
        // The order in the array has to follow corresponding enum's order in ViewEdge
        var constraints = [
            self.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor, constant: -insets.right),
            self.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor, constant: -insets.bottom)
        ]
        constraints.remove(at: edge.rawValue)
        NSLayoutConstraint.activate(constraints)
    }
}
