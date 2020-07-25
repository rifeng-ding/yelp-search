//
//  Network.swift
//  Yelp Search
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import Apollo

class Network {

    let YelpAPIKey = "a5yxz4J9Ut959boT7u4Agla43oRGl5HP4nTDF7z7-ZNhl6ymeSKJutXeaoJcWwV0a6wr1wlKOOhMCm91nJn6lQtRi-8l5mwUeu2_8EiEolca-6mwGcMVRGy1NB8cX3Yx"

    static let shared = Network()

    private(set) lazy var apollo: ApolloClient = {
        let httpNetworkTransport = HTTPNetworkTransport(url: URL(string: "https://api.yelp.com/v3/graphql")!)
        httpNetworkTransport.delegate = self
        return ApolloClient(networkTransport: httpNetworkTransport)
    }()
}

extension Network: HTTPNetworkTransportPreflightDelegate {
    func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
        return true
    }

    func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
        request.addValue("Bearer \(YelpAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("en-CA", forHTTPHeaderField: "Accept-Language")
    }
}
