//
//  ReviewService.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import Combine

typealias Review = ReviewSnippetsQuery.Data.Review.Review

class ReviewService: Service {

    private(set) var fetchReviewsCancellable: AnyCancellable?

    func fetchReviewSnippets(for businessId: String) -> AnyPublisher<[Review]?, Error> {
        let query = ReviewSnippetsQuery(businessId: businessId)
        return Future<[Review]?, Error> { [weak self] (promise) in
            self?.fetchReviewsCancellable = self?.fetch(query: query).sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    self?.fetchReviewsCancellable = nil
                }
            }) { (data) in
                promise(.success(data?.reviews?.review?.compactMap({ $0 })))
            }
        }.eraseToAnyPublisher()
    }
}
