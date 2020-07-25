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

    var numberOfCells: Int {
        return _businesses.count
    }

    init(service: BusinessSearch) {
        self.service = service
    }

    func loadSearchResults() {
        searchCancellable = service.fetchSearchResult(for: "s", pageNumber: pageNumber).sink(receiveCompletion: { [weak self] (completion) in
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

    func cancelCurrentSearch() {
        searchCancellable?.cancel()
    }

    func name(for indexPath: IndexPath) -> String? {
        return _businesses[indexPath.item].name
    }

    func info(for indexPath: IndexPath) -> String {
        let business = _businesses[indexPath.item]
        let rating = String(format: "%.1f", business.rating ?? 0)
        let numberOfRating = "\(business.reviewCount ?? 0)  Reviews"
        return "\(rating) Star(s)/ \(numberOfRating)"
    }

    func distiance(for indexPath: IndexPath) -> String? {
        let business = _businesses[indexPath.item]
        guard let distance = business.distiance(from: mockCoordinate) else {
            return nil
        }
        return distanceFormatter.string(fromDistance: distance)
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
