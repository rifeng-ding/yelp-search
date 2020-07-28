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
private let paginationCellIndexOffset = 6
private let pageSize = 20

class BusinessSearchViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyStateLabel: UILabel!

    private(set) var viewModel: BusinessSearchViewModel!

    private var emptyStateCancellable: AnyCancellable?
    private var searchErrorCancellable: AnyCancellable?
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = BusinessSearchViewModel(
            service: BusinessSearchService(pageSize: 20),
            dataSource: generateDataSource(for: collectionView)
        )

        title = viewModel.title
        updateEmptyStateLabel(shouldShow: true)
        configureSearchController()
        configureCollectionView()
        subscribeToViewModel()
    }

    private func configureCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: gridSpacing, left: gridSpacing, bottom: gridSpacing, right: gridSpacing)
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = gridSpacing
        flowLayout.minimumInteritemSpacing = gridSpacing
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

    func generateDataSource(for collectionView: UICollectionView) -> BusinessSearchViewModel.DataSource {
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [weak self] (collectionView, indexPath, business) -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BusinessSearchCell.reuseIdentifier,
                for: indexPath
                ) as! BusinessSearchCell

            let availableHorizentalWidth = collectionView.frame.width - gridSpacing * 3
            cell.width = floor(availableHorizentalWidth / 2)
            cell.nameLabel.text = business.name
            cell.infoLabel.text = business.basicInforamtion
            cell.distanceLabel.text = business.formattedDistance(from: self.viewModel.userLocation)
            cell.imageView.loadImage(
                fromURL: business.imageURL,
                defaultImage: self.viewModel.defaultImage
            )
            return cell
        }
    }
}

extension BusinessSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard viewModel.numberOfCells >= pageSize else {
            return
        }
        if viewModel.numberOfCells - indexPath.item == paginationCellIndexOffset {
            print("loading page: reached cell \(indexPath.item)/\(viewModel.numberOfCells)")
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
