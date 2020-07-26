//
//  BusinessDetailViewModel.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-26.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit
import Combine

class BusinessDetailViewModel: DefaultImageLoading {

    private(set) var reviewsUpdate = PassthroughSubject<[Review]?, Never>()
    private(set) var errorUpdate = PassthroughSubject<Error, Never>()
    let business: Business
    let service: ReviewService
    private(set) var loadReviewCancellable: AnyCancellable?
    private var reviews = [Review]()

    init(business: Business, service: ReviewService) {
        self.business = business
        self.service = service
    }

    var emptyStateMessage: String {
        return "No reviews yet or the business is no longer available."
    }

    var shouldShowEmptyState: Bool {
        return reviews.count == 0
    }

    var name: String? {
        return business.name
    }

    var address: String? {
        return business.location?.formattedAddress
    }

    var photoURL: String? {
        guard let photoURL = business.photos?.first else {
            return nil
        }
        return photoURL
    }

    func loadReviews() {
        guard let businessId = business.id else {
            return
        }
        loadReviewCancellable = service.fetchReviewSnippets(for: businessId)
            .sink(
                receiveCompletion: { [weak self] (completion) in
                    switch completion {
                    case .failure(let error):
                        self?.errorUpdate.send(error)
                    case .finished:
                        self?.loadReviewCancellable = nil
                    }
                }, receiveValue: { [weak self] (reviews) in
                    guard let reviews = reviews else {
                        return
                    }
                    self?.reviews = reviews
                    self?.reviewsUpdate.send(reviews)
            }
        )
    }

    var numberOfCells: Int {
        return reviews.count
    }

    func userName(for indexPath: IndexPath) -> String? {
        return reviews[indexPath.row].user?.name
    }

    func rating(for indexPath: IndexPath) -> String? {
        guard let rating = reviews[indexPath.row].rating else {
            return nil
        }
        return "\(rating) Star(s)"
    }

    func reviewContent(for indexPath: IndexPath) -> String? {
        return reviews[indexPath.row].text
    }
}
