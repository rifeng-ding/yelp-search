//
//  ProgrammaticViewController.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

class ProgrammaticViewController: UIViewController, ProgrammaticUI {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSubviews()
        setupConstraints()
    }

    func configureSubviews() {
        // Should be overridden by subclass
    }

    func setupConstraints() {
        // Should be overridden by subclass
    }
}

