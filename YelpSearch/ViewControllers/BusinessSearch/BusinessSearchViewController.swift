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
private let paginationCellIndexOffset = 4
private let pageSize = 20

class BusinessSearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    let viewModel = BusinessSearchViewModel(service: BusinessSearchService(pageSize: 20))

    private var searchResultCancellable: AnyCancellable?
    private var searchErrorCancellable: AnyCancellable?
    private let searchController = UISearchController(searchResultsController: nil)


    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        configureSearchController()
        configureCollectionView()
        searchResultCancellable = viewModel.searchResultUpdate.sink { [weak self] (newResultRange) in
            if newResultRange.startIndex == 0 {
                self?.collectionView.reloadData()
            } else {
                var newIndexPathes = [IndexPath]()
                for i in newResultRange {
                    newIndexPathes.append(IndexPath(item: i, section: 0))
                }
                self?.collectionView.insertItems(at: newIndexPathes)
            }
        }

        searchErrorCancellable = viewModel.errorUpdate.sink { [weak self] (error) in
            self?.handle(error)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        viewModel.search(for: "bagel")
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
        searchController.searchBar.placeholder = "Search on Yelp"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension BusinessSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BusinessSearchCell.reuseIdentifier,
            for: indexPath
        ) as! BusinessSearchCell

        let availableHorizentalWidth = collectionView.frame.width - gridSpacing * 3
        cell.width = floor(availableHorizentalWidth / 2)
        cell.nameLabel.text = viewModel.name(for: indexPath)
        cell.infoLabel.text = viewModel.info(for: indexPath)
        cell.distanceLabel.text = viewModel.distiance(for: indexPath)
        cell.imageView.loadImage(fromURL: viewModel.imageURL(for: indexPath))
        return cell
    }
}

extension BusinessSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.numberOfCells - indexPath.item == paginationCellIndexOffset {
            print("loading page: reached cell")
            viewModel.loadMoreResultsForCurrentSearchTerm()
        }
    }
}

extension BusinessSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTerm = searchController.searchBar.text, searchTerm.count > 0 {
            viewModel.search(for: searchTerm)
        } else {
            viewModel.clearSearchResult()
        }
    }
}
