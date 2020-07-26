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

typealias Search = BusinessSearchQuery.Data.Search
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
    ) -> AnyPublisher<Search?, Error>
}

class BusinessSearchService: Service, BusinessSearch {

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
    ) -> AnyPublisher<Search?, Error> {
        let offset = pageNumber * pageSize
        let query = BusinessSearchQuery(
            term: searchTerm,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            limit: pageSize,
            offset: offset, sortBy:
            sorting.rawValue
        )
        return Future<Search?, Error> { [weak self] (promise) in
            self?.searchCancellable = self?.fetch(query: query).sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    self?.searchCancellable = nil
                }
            }) { (data) in
                promise(.success(data?.search))
            }
        }.eraseToAnyPublisher()
    }
}
