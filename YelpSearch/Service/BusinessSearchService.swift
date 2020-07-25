//
//  BusinessSearchService.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import Combine

typealias Business = BusinessSearchQuery.Data.Search.Business


protocol BusinessSearch {
    var pageSize: Int { get }
    func fetchSearchResult(for searchTerm: String, pageNumber: Int) -> AnyPublisher<[Business], Error>
}

class BusinessSearchService: BusinessSearch, Service {
    let pageSize: Int
    init(pageSize: Int) {
        self.pageSize = pageSize
    }

    private(set) var searchCancellable: AnyCancellable?

    func fetchSearchResult(for searchTerm: String, pageNumber: Int) -> AnyPublisher<[Business], Error> {
        let offset = pageNumber * pageSize
        return Future<[Business], Error> { [weak self] (promise) in
            self?.searchCancellable = self?.fetch(query: BusinessSearchQuery()).sink(receiveCompletion: { [weak self] (completion) in
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
