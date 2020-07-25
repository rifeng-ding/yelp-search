// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class BusinessSearchQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query businessSearch($term: String, $latitude: Float, $longitude: Float, $limit: Int, $offset: Int, $sortBy: String) {
      search(term: $term, latitude: $latitude, longitude: $longitude, limit: $limit, offset: $offset, sort_by: $sortBy) {
        __typename
        total
        business {
          __typename
          name
          id
          url
          display_phone
          review_count
          rating
          price
          photos
          coordinates {
            __typename
            latitude
            longitude
          }
        }
      }
    }
    """

  public let operationName: String = "businessSearch"

  public var term: String?
  public var latitude: Double?
  public var longitude: Double?
  public var limit: Int?
  public var offset: Int?
  public var sortBy: String?

  public init(term: String? = nil, latitude: Double? = nil, longitude: Double? = nil, limit: Int? = nil, offset: Int? = nil, sortBy: String? = nil) {
    self.term = term
    self.latitude = latitude
    self.longitude = longitude
    self.limit = limit
    self.offset = offset
    self.sortBy = sortBy
  }

  public var variables: GraphQLMap? {
    return ["term": term, "latitude": latitude, "longitude": longitude, "limit": limit, "offset": offset, "sortBy": sortBy]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("search", arguments: ["term": GraphQLVariable("term"), "latitude": GraphQLVariable("latitude"), "longitude": GraphQLVariable("longitude"), "limit": GraphQLVariable("limit"), "offset": GraphQLVariable("offset"), "sort_by": GraphQLVariable("sortBy")], type: .object(Search.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(search: Search? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "search": search.flatMap { (value: Search) -> ResultMap in value.resultMap }])
    }

    /// Search for businesses on Yelp.
    public var search: Search? {
      get {
        return (resultMap["search"] as? ResultMap).flatMap { Search(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "search")
      }
    }

    public struct Search: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Businesses"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("total", type: .scalar(Int.self)),
          GraphQLField("business", type: .list(.object(Business.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(total: Int? = nil, business: [Business?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Businesses", "total": total, "business": business.flatMap { (value: [Business?]) -> [ResultMap?] in value.map { (value: Business?) -> ResultMap? in value.flatMap { (value: Business) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Total number of businesses found.
      public var total: Int? {
        get {
          return resultMap["total"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "total")
        }
      }

      /// A list of business Yelp finds based on the search criteria.
      public var business: [Business?]? {
        get {
          return (resultMap["business"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Business?] in value.map { (value: ResultMap?) -> Business? in value.flatMap { (value: ResultMap) -> Business in Business(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Business?]) -> [ResultMap?] in value.map { (value: Business?) -> ResultMap? in value.flatMap { (value: Business) -> ResultMap in value.resultMap } } }, forKey: "business")
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Business"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("id", type: .scalar(String.self)),
            GraphQLField("url", type: .scalar(String.self)),
            GraphQLField("display_phone", type: .scalar(String.self)),
            GraphQLField("review_count", type: .scalar(Int.self)),
            GraphQLField("rating", type: .scalar(Double.self)),
            GraphQLField("price", type: .scalar(String.self)),
            GraphQLField("photos", type: .list(.scalar(String.self))),
            GraphQLField("coordinates", type: .object(Coordinate.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, id: String? = nil, url: String? = nil, displayPhone: String? = nil, reviewCount: Int? = nil, rating: Double? = nil, price: String? = nil, photos: [String?]? = nil, coordinates: Coordinate? = nil) {
          self.init(unsafeResultMap: ["__typename": "Business", "name": name, "id": id, "url": url, "display_phone": displayPhone, "review_count": reviewCount, "rating": rating, "price": price, "photos": photos, "coordinates": coordinates.flatMap { (value: Coordinate) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Name of this business.
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// Yelp ID of this business.
        public var id: String? {
          get {
            return resultMap["id"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// URL for business page on Yelp.
        public var url: String? {
          get {
            return resultMap["url"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }

        /// Phone number of the business formatted nicely to be displayed to users. The format is the standard phone number format for the business's country.
        public var displayPhone: String? {
          get {
            return resultMap["display_phone"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "display_phone")
          }
        }

        /// Number of reviews for this business.
        public var reviewCount: Int? {
          get {
            return resultMap["review_count"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "review_count")
          }
        }

        /// Rating for this business (value ranges from 1, 1.5, ... 4.5, 5).
        public var rating: Double? {
          get {
            return resultMap["rating"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "rating")
          }
        }

        /// Price level of the business. Value is one of $, $$, $$$ and $$$$ or null if we don't have price available for the business.
        public var price: String? {
          get {
            return resultMap["price"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "price")
          }
        }

        /// URLs of up to three photos of the business.
        public var photos: [String?]? {
          get {
            return resultMap["photos"] as? [String?]
          }
          set {
            resultMap.updateValue(newValue, forKey: "photos")
          }
        }

        /// The coordinates of this business.
        public var coordinates: Coordinate? {
          get {
            return (resultMap["coordinates"] as? ResultMap).flatMap { Coordinate(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "coordinates")
          }
        }

        public struct Coordinate: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Coordinates"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("latitude", type: .scalar(Double.self)),
              GraphQLField("longitude", type: .scalar(Double.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(latitude: Double? = nil, longitude: Double? = nil) {
            self.init(unsafeResultMap: ["__typename": "Coordinates", "latitude": latitude, "longitude": longitude])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The latitude of this business.
          public var latitude: Double? {
            get {
              return resultMap["latitude"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "latitude")
            }
          }

          /// The longitude of this business.
          public var longitude: Double? {
            get {
              return resultMap["longitude"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "longitude")
            }
          }
        }
      }
    }
  }
}
