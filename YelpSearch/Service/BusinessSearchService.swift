//
//  BusinessSearchService.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import MapKit
import Combine

typealias Business = BusinessSearchQuery.Data.Search.Business

/// Defined based on https://www.yelp.com/developers/graphql/query/search
enum BusinessSearchSorting: String {
    case bestMatch = "best_match"
    case distance
    case rating
    case review_count = "review_count"
}

protocol BusinessSearch {
    var pageSize: Int { get }
    func fetchSearchResult(
        for searchTerm: String,
        coordinate: CLLocationCoordinate2D,
        pageNumber: Int,
        sorting: BusinessSearchSorting
    ) -> AnyPublisher<[Business], Error>
}

class BusinessSearchService: BusinessSearch, Service {

    let pageSize: Int
    init(pageSize: Int) {
        self.pageSize = pageSize
    }

    private(set) var searchCancellable: AnyCancellable?

    func fetchSearchResult(
        for searchTerm: String,
        coordinate: CLLocationCoordinate2D,
        pageNumber: Int,
        sorting: BusinessSearchSorting
    ) -> AnyPublisher<[Business], Error> {
        let offset = pageNumber * pageSize
        let query = BusinessSearchQuery(
            term: searchTerm,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            limit: pageSize,
            offset: offset, sortBy:
            sorting.rawValue
        )
        return Future<[Business], Error> { [weak self] (promise) in
            self?.searchCancellable = self?.fetch(query: query).sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    self?.searchCancellable = nil
                }
            }) { (data) in
                var results = [Business]()
                if let businesses = data?.search?.business {
                    results = businesses.compactMap { $0 }
                }
                promise(.success(results))
            }
        }.eraseToAnyPublisher()
    }
}
