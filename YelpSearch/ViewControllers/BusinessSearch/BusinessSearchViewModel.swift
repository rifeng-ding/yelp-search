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

class BusinessSearchViewModel {
    let service: BusinessSearch
    let mockCoordinate = CLLocationCoordinate2D(latitude: 45.4990267, longitude: -73.5562752)

    typealias NewResultRange = Range<Int>

    private(set) var searchResultUpdate = PassthroughSubject<NewResultRange, Never>()
    private(set) var errorUpdate = PassthroughSubject<Error, Never>()
    private var _businesses = [Business]()

    private(set) var pageNumber = 0
    private(set) var hasNextPage = true
    private(set) var searchTerm: String?
    private var searchCancellable: AnyCancellable?
    private let distanceFormatter = MKDistanceFormatter()

    let title = "Yelp Search"

    var numberOfCells: Int {
        return _businesses.count
    }

    init(service: BusinessSearch) {
        self.service = service
    }

    func search(for searchTerm: String) {
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
        _businesses = [Business]()
    }

    func cancelCurrentSearch() {
        searchCancellable?.cancel()
    }

    func name(for indexPath: IndexPath) -> String? {
        return _businesses[indexPath.item].name
    }

    func info(for indexPath: IndexPath) -> String {
        let business = _businesses[indexPath.item]
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
        let business = _businesses[indexPath.item]
        guard let distance = business.distiance(from: mockCoordinate) else {
            return nil
        }
        return distanceFormatter.string(fromDistance: distance)
    }

    func imageURL(for indexPath: IndexPath) -> String? {
        let business = _businesses[indexPath.item]
        guard let photoURL = business.photos?.first else {
            return nil
        }
        return photoURL
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
        ).sink(receiveCompletion: { [weak self] (completion) in
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
                    let currentResultCount = self._businesses.count
                    self._businesses.append(contentsOf: businesses)
                    self.searchResultUpdate.send(currentResultCount ..< (currentResultCount + businesses.count))
                    self.hasNextPage = total > self._businesses.count
                }
                //TODO: what if unwrapping failed?!?!?!!?
        })
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
