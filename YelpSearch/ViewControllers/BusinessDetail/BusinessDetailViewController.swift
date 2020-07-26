//
//  BusinessDetailViewController.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit
import Combine

private let headerViewHeight: CGFloat = 320

class BusinessDetailViewController: ProgrammaticViewController {

    let viewModel: BusinessDetailViewModel
    let headerView = BusinessHeaderView()

    private var reviewsCancellable: AnyCancellable?
    private var errorCancellable: AnyCancellable?

    init(viewModel: BusinessDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureSubviews() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.nameLabel.text = viewModel.name
        headerView.addressLabel.text = viewModel.address
        headerView.imageView.loadImage(fromURL: viewModel.photoURL)
        view.addSubview(headerView)
    }

    override func setupConstraints() {
        headerView.constraintToSuperviewEdges(except: .bottom)
        headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadReviews()
    }

    private func subscribeToViewModel() {
        reviewsCancellable = viewModel.reviewsUpdate.sink { (reviews) in
            guard let reviews = reviews else {
                return
            }
            reviews.forEach { (review) in
                print(review)
            }
        }
        errorCancellable = viewModel.errorUpdate.sink { [weak self] (error) in
            self?.handle(error)
        }
    }
}

