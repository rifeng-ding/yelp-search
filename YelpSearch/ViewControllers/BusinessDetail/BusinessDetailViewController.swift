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
    let emptyStateLabel = UILabel(textStyle: .title3, color: .secondaryLabel, numberOfLine: 0)
    private(set) lazy var tableView = buildTableView()

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
        headerView.imageView.loadImage(
            fromURL: viewModel.photoURL,
            defaultImage: viewModel.defaultImage
        )
        view.addSubview(headerView)

        view.addSubview(tableView)

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = viewModel.emptyStateMessage
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
    }

    override func setupConstraints() {
        headerView.constraintToSuperviewEdges(except: .bottom)
        headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true

        tableView.constraintToSuperviewEdges(except: .top)
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.s4)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToViewModel()
        viewModel.loadReviews()
    }

    private func subscribeToViewModel() {
        reviewsCancellable = viewModel.reviewsUpdate.sink { [weak self] (reviews) in
            guard let self = self else {
                return
            }
            self.emptyStateLabel.isHidden = !self.viewModel.shouldShowEmptyState
            self.tableView.reloadData()
        }
        errorCancellable = viewModel.errorUpdate.sink { [weak self] (error) in
            guard let self = self else {
                return
            }
            self.handle(error)
            self.emptyStateLabel.isHidden = !self.viewModel.shouldShowEmptyState
        }
    }

    private func buildTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BusinessReviewCell.self, forCellReuseIdentifier: BusinessReviewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }
}

extension BusinessDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BusinessReviewCell.reuseIdentifier,
            for: indexPath
        ) as! BusinessReviewCell
        cell.userNameLabel.text = viewModel.userName(for: indexPath)
        cell.ratingLabel.text = viewModel.rating(for: indexPath)
        cell.commentLabel.text = viewModel.reviewContent(for: indexPath)
        return cell
    }
}

