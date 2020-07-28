//
//  BusinessSearchViewModel.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import Combine
import MapKit

private let defaultLocation = CLLocation(
    latitude: 45.4990267,
    longitude: -73.5562752
)

struct NoLocationPermissionError: LocalizedError {
    var errorDescription: String? {
        return "User denied permisson to use GPS location. A default location in Montreal will be used."
    }
}

class BusinessSearchViewModel: DefaultImageLoading {

    typealias NewResultRange = Range<Int>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Business>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Business>

    enum Section {
        case main
    }

    // Dependencies
    let service: BusinessSearch
    let locationUtility: LocationUtility
    let dataSource: DataSource

    let shouldShowEmptyStateUpdate = PassthroughSubject<Bool, Never>()
    let errorUpdate = PassthroughSubject<Error, Never>()
    private var businesses = [Business]() {
        didSet {
            shouldShowEmptyStateUpdate.send(businesses.count == 0)
        }
    }
    private var snapshot: Snapshot?
    private(set) var pageNumber = 0
    private(set) var hasNextPage = true
    private(set) var searchTerm: String?
    private var searchCancellable: AnyCancellable?
    private var locationUpdateCancellable: AnyCancellable?
    private var locationPermissonCancellable: AnyCancellable?

    let title = "Yelp Search"
    let searchBarPlaceholder = "Search on Yelp"

    private(set) var gpsLocation: CLLocation?
    var currentLocation: CLLocation {
        return gpsLocation ?? defaultLocation
    }

    var numberOfCells: Int {
        return businesses.count
    }

    var emptyStateMessage: String {
        return searchTerm != nil ? "No result matches your search." : "Enter the nearby business you want to search for."
    }

    init(service: BusinessSearch, locationUtility: LocationUtility, dataSource: DataSource) {
        self.service = service
        self.dataSource = dataSource
        self.locationUtility = locationUtility
    }

    func startUpdatinLocation() {
        if locationUtility.hasAskedPermission {
            updatingCurrentLocation(isPermissionGranted: locationUtility.isPermissionGranted)
        } else {
            locationPermissonCancellable = locationUtility.permissionRequestResult.sink {
                [weak self] (isGranted) in
                guard let self = self else {
                    return
                }
                self.updatingCurrentLocation(isPermissionGranted: isGranted)
            }
            locationUtility.requestPermission()
        }
    }

    private func updatingCurrentLocation(isPermissionGranted: Bool) {
        if isPermissionGranted {
            locationUpdateCancellable = locationUtility.$currentLocation.sink { [weak self] (location) in
                self?.gpsLocation = location
            }
            locationUtility.startUpdatingCurrentLocation()
        } else {
            errorUpdate.send(NoLocationPermissionError())
        }
    }

    func search(for searchTerm: String) {
        guard searchTerm != self.searchTerm else {
            return
        }
        clearSearchResult()
        self.searchTerm = searchTerm
        search(for: searchTerm, resetPagination: true)
    }

    func loadMoreResultsForCurrentSearchTerm() {
        guard let searchTerm = searchTerm,
            searchCancellable == nil,
            hasNextPage else {
            return
        }
        search(for: searchTerm, resetPagination: false)
    }

    func clearSearchResult() {
        cancelCurrentSearch()
        businesses = [Business]()
        applySnapshot(forBusiness: [], animated: true)
    }

    func cancelCurrentSearch() {
        searchTerm = nil
        searchCancellable?.cancel()
        searchCancellable = nil
    }

    func business(for indexPath: IndexPath) -> Business? {
        return dataSource.itemIdentifier(for: indexPath)
    }

    private func search(for searchTerm: String, resetPagination: Bool) {
        if resetPagination {
            pageNumber = 0
        }

        searchCancellable?.cancel()
        searchCancellable = service.fetchSearchResult(
            for: searchTerm,
            location: currentLocation,
            pageNumber: pageNumber,
            sorting: .distance
        ).sink(
            receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .failure(let error):
                    self?.errorUpdate.send(error)
                case .finished:
                    self?.pageNumber += 1
                    self?.searchCancellable = nil
                }
            }, receiveValue: { [weak self] (search) in
                guard let self = self else {
                    return
                }
                if let total = search?.total,
                    let businesses = search?.business?.compactMap({ $0 }) {
                    let currentResultCount = self.dataSource.snapshot().numberOfItems
                    self.businesses.append(contentsOf: businesses)
                    self.hasNextPage = total > currentResultCount
                    self.applySnapshot(forBusiness: self.businesses, animated: true)
                }
            }
        )
    }

    func applySnapshot(forBusiness businesses: [Business], animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(businesses)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension Business {

    func formattedDistance(from userLocation: CLLocation) -> String? {
        guard let rawLatitude = coordinates?.latitude,
            let rawLongitude = coordinates?.longitude else {
            return nil
        }
        let businessLocaiton = CLLocation(latitude: rawLatitude, longitude: rawLongitude)
        return MKDistanceFormatter().string(fromDistance: userLocation.distance(from: businessLocaiton))
    }

    var basicInforamtion: String {
        var ratingCopy = "Not enough ratings"

        if let rating = rating {
            ratingCopy = String(format: "%.1f/5 stars", rating)
        } else {
            // when there's no rating, there's probably no price range
            return ratingCopy
        }

        var parts = [ratingCopy]
        if let priceRange = price  {
            parts.append(priceRange)
        }
        return parts.joined(separator: ", ")
    }

    var imageURL: String? {
        guard let photoURL = photos?.first else {
            return nil
        }
        return photoURL
    }
}
