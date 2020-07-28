//
//  ViewController.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit
import Combine

private let gridSpacing = Spacing.s3
private let paginationCellIndexOffset = 8
private let pageSize = 20

class BusinessSearchViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyStateLabel: UILabel!

    private(set) var viewModel: BusinessSearchViewModel!

    private var emptyStateCancellable: AnyCancellable?
    private var searchErrorCancellable: AnyCancellable?
    private var isFirstAppear: Bool = true
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = BusinessSearchViewModel(
            service: BusinessSearchService(pageSize: 20),
            locationUtility: LocationUtility.shared,
            dataSource: generateDataSource(for: collectionView)
        )

        title = viewModel.title
        updateEmptyStateLabel(shouldShow: true)
        configureSearchController()
        configureCollectionView()
        subscribeToViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            viewModel.startUpdatinLocation()
            isFirstAppear = false
        }
    }

    private func configureCollectionView() {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let businessItem = NSCollectionLayoutItem(layoutSize: itemSize)
        businessItem.contentInsets = NSDirectionalEdgeInsets(
            top: gridSpacing,
            leading: gridSpacing,
            bottom: gridSpacing,
            trailing: gridSpacing
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: businessItem,
            count: 2
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func subscribeToViewModel() {

        emptyStateCancellable = viewModel.shouldShowEmptyStateUpdate.sink(receiveValue: { [weak self] (shouldShowEmptyState) in
            self?.updateEmptyStateLabel(shouldShow: shouldShowEmptyState)
        })

        searchErrorCancellable = viewModel.errorUpdate.sink { [weak self] (error) in
            self?.handle(error)
        }
    }

    private func generateDataSource(for collectionView: UICollectionView) -> BusinessSearchViewModel.DataSource {
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [weak self] (collectionView, indexPath, business) -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BusinessSearchCell.reuseIdentifier,
                for: indexPath
                ) as! BusinessSearchCell

            cell.nameLabel.text = business.name
            cell.infoLabel.text = business.basicInforamtion
            cell.distanceLabel.text = business.formattedDistance(from: self.viewModel.currentLocation)
            cell.imageView.loadImage(
                fromURL: business.imageURL,
                defaultImage: self.viewModel.defaultImage
            )
            return cell
        }
    }
}

extension BusinessSearchViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard viewModel.numberOfCells >= pageSize else {
            return
        }
        if viewModel.numberOfCells - indexPath.item == paginationCellIndexOffset {
            viewModel.loadMoreResultsForCurrentSearchTerm()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let business = viewModel.business(for: indexPath) else {
            return
        }
        let detailViewModel = BusinessDetailViewModel(business: business, service: ReviewService())
        let detailViewController = BusinessDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func updateEmptyStateLabel(shouldShow: Bool) {
        emptyStateLabel.text = viewModel.emptyStateMessage
        emptyStateLabel.isHidden = !shouldShow
    }
}

extension BusinessSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text, searchTerm.count > 0 {
            viewModel.search(for: searchTerm)
            emptyStateLabel.isHidden = true
        } else {
            viewModel.clearSearchResult()
            updateEmptyStateLabel(shouldShow: true)
        }
    }
}
