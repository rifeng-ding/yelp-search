//
//  Business+Hashable.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-27.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation

extension Business: Hashable {

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    public static func == (lhs: BusinessSearchQuery.Data.Search.Business, rhs: BusinessSearchQuery.Data.Search.Business) -> Bool {
        return lhs.id == rhs.id
    }
}
