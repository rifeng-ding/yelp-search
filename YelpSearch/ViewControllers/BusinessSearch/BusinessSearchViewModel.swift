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

class BusinessSearchViewModel: DefaultImageLoading {
    let service: BusinessSearch
    let mockCoordinate = CLLocationCoordinate2D(latitude: 45.4990267, longitude: -73.5562752)

    typealias NewResultRange = Range<Int>

    private(set) var searchResultUpdate = PassthroughSubject<NewResultRange?, Never>()
    private(set) var errorUpdate = PassthroughSubject<Error, Never>()
    private var businesses = [Business]()

    private(set) var pageNumber = 0
    private(set) var hasNextPage = true
    private(set) var searchTerm: String?
    private var searchCancellable: AnyCancellable?
    private let distanceFormatter = MKDistanceFormatter()

    let title = "Yelp Search"

    var numberOfCells: Int {
        return businesses.count
    }

    var emptyStateMessage: String {
        return searchTerm != nil ? "No result matches your search." : "Enter the nearby business you want to search for."
    }

    var shouldShowEmptyState: Bool {
        return businesses.count == 0
    }

    init(service: BusinessSearch) {
        self.service = service
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
        print("loading page: more")
        search(for: searchTerm, resetPagination: false)
    }

    func clearSearchResult() {
        cancelCurrentSearch()
        businesses = [Business]()
        searchResultUpdate.send(nil)
    }

    func cancelCurrentSearch() {
        searchTerm = nil
        searchCancellable?.cancel()
        searchCancellable = nil
    }

    func name(for indexPath: IndexPath) -> String? {
        return businesses[indexPath.item].name
    }

    func info(for indexPath: IndexPath) -> String {
        let business = businesses[indexPath.item]
        var ratingCopy = "Not enough ratings"

        if let rating = business.rating {
            ratingCopy = String(format: "%.1f/5 stars", rating)
        } else {
            // when there's no rating, there's probably no price range
            return ratingCopy
        }

        var parts = [ratingCopy]
        if let priceRange = business.price  {
            parts.append(priceRange)
        }
        return parts.joined(separator: ", ")
    }

    func distiance(for indexPath: IndexPath) -> String? {
        let business = businesses[indexPath.item]
        guard let distance = business.distiance(from: mockCoordinate) else {
            return nil
        }
        return distanceFormatter.string(fromDistance: distance)
    }

    func imageURL(for indexPath: IndexPath) -> String? {
        let business = businesses[indexPath.item]
        guard let photoURL = business.photos?.first else {
            return nil
        }
        return photoURL
    }

    func business(for indexPath: IndexPath) -> Business? {
        guard indexPath.item < businesses.count else {
            return nil
        }
        return businesses[indexPath.item]
    }

    private func search(for searchTerm: String, resetPagination: Bool) {
        if resetPagination {
            pageNumber = 0
        }

        print("loading page: \(pageNumber)")

        searchCancellable?.cancel()
        searchCancellable = service.fetchSearchResult(
            for: searchTerm,
            coordinate: mockCoordinate,
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
                    let currentResultCount = self.businesses.count
                    self.businesses.append(contentsOf: businesses)
                    self.searchResultUpdate.send(currentResultCount ..< (currentResultCount + businesses.count))
                    self.hasNextPage = total > self.businesses.count
                }
            }
        )
    }
}

extension Business {
    func distiance(from targetCoordinates: CLLocationCoordinate2D) -> Double? {
        guard let rawLatitude = coordinates?.latitude,
            let rawLongitude = coordinates?.longitude else {
            return nil
        }
        let businessLocaiton = CLLocation(latitude: rawLatitude, longitude: rawLongitude)
        let targetLocation = CLLocation(
            latitude: targetCoordinates.latitude,
            longitude: targetCoordinates.longitude
        )
        return targetLocation.distance(from: businessLocaiton)
    }
}
