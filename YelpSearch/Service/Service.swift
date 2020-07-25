//
//  Service.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import Combine
import Apollo

struct GraphQLQuerryError: Error {
    let message: String
    var localizedDescription: String {
        return message
    }
}

protocol Service {
    func fetch <Query: GraphQLQuery>(query: Query) -> AnyPublisher<Query.Data?, Error>
}

extension Service {
    func fetch <Query: GraphQLQuery>(query: Query) -> AnyPublisher<Query.Data?, Error> {
        return Future<Query.Data?, Error> { (promise) in
            Network.shared.apollo.fetch(query: query) { result in
                switch result {
                case .success(let graphQLResult):
                    guard graphQLResult.errors == nil else {
                        let message = graphQLResult.errors!
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
                        promise(.failure(GraphQLQuerryError(message: message)))
                        return
                    }
                    promise(.success(graphQLResult.data))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
