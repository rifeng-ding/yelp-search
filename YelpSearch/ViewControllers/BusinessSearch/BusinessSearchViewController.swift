//
//  ViewController.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit
import Combine

class BusinessSearchViewController: UIViewController {

    private let gridSpacing = Spacing.s3

    @IBOutlet weak var collectionView: UICollectionView!

    let viewModel = BusinessSearchViewModel(service: BusinessSearchService(pageSize: 10))

    private var searchResultCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        searchResultCancellable = viewModel.searchResults.sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .failure(let error):
                self?.handle(error)
            case .finished:
                break
            }
        }) { [weak self] (_) in
            self?.collectionView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadSearchResults()
    }

    private func configureCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: gridSpacing, left: gridSpacing, bottom: gridSpacing, right: gridSpacing)
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = gridSpacing
        flowLayout.minimumInteritemSpacing = gridSpacing
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

}
