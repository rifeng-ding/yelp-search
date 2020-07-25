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

    private(set) var searchResults = PassthroughSubject<[Business], Error>()
    private var _businesses = [Business]() {
        didSet {
            searchResults.send(_businesses)
        }
    }

    private(set) var pageNumber = 0
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
        searchCancellable?.cancel()
        searchCancellable = service.fetchSearchResult(
            for: searchTerm,
            coordinate: mockCoordinate,
            pageNumber: pageNumber,
            sorting: .distance
        ).sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .failure(let error):
                self?.searchResults.send(completion: .failure(error))
            case .finished:
                self?.searchCancellable = nil
            }
            }, receiveValue: { [weak self] (businesses) in
                self?._businesses.append(contentsOf: businesses)
        })
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
