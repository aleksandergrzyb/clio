//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

/// Encapsulates information about HTTP method.
///
/// - get:  Get HTTP method.
/// - post: Post HTTP method with request body.
/// - put:  Put HTTP method with request body.
enum HttpMethod<Body> {
    case get
    case post(Body)
    case put(Body)
}

/// Represents possible errors that could occur when using `APIClient` class.
///
/// - jsonParsingFailed:    JSON parsing failed.
/// - unknownFailureReason: Unknown failure reason. Occurs when `completionHandler`
/// of `URLSession` will pass `nil` `data` and `nil` `error`.
enum APIClientError: Error {
    case jsonParsingFailed(error: Error)
    case unknownFailureReason
}

extension APIClientError {
    var localizedDescription: String {
        switch self {
        case .jsonParsingFailed(let error):
            return "Server data could not be parsed because of error: \(error.localizedDescription)"
        case .unknownFailureReason:
            return "Unknown error occured. Please try again later."
        }
    }
}

/// Used to represent whether a request was successful or encountered an error.
///
/// - success: Success case with associated value.
/// - failure: Failure case with associated error.
enum Result<A> {
    case success(A)
    case failure(Error)
}

extension HttpMethod {

    /// The HTTP method string for `URLRequest` `httpMethod` property.
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        }
    }

    /// Transforms `Body` of `.post` and `.put` methods using `f` function.
    ///
    /// - parameter f: Function that transforms body from one type to another
    /// (for `URLRequest` from dictionary to `Data`).
    ///
    /// - returns: Returns transformed `HttpMethod`.
    func transformBody<B>(transform: (Body) -> B) -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let body):
            return .post(transform(body))
        case .put(let body):
            return .put(transform(body))
        }
    }
}

/// Encapsulate all information used to perform request for specified resource.
struct Resource<A> {

    /// Resource endpoint path.
    let path: String

    /// Resource params.
    let params: [String: String]

    /// Method used for performing request.
    let method: HttpMethod<Data>

    /// Parse function that will transform data received from endpoint.
    let parse: (Data) -> Result<A>
}

extension Resource {

    /// Creates resource with given configuration.
    ///
    /// - parameter path:       Resource endpoint path.
    /// - parameter method:    Method used for performing request (defaults to GET method).
    /// - parameter parseJSON: Parse function that will transform data received from endpoint.
    ///
    /// - returns: Resource with initialized configuration.
    init(path: String,
         method: HttpMethod<AnyObject> = .get,
         params: [String: String] = [:],
         parseJSON: @escaping (Any) -> Result<A>) {
        self.path = path
        self.params = params
        self.method = method.transformBody { json in
            try! JSONSerialization.data(withJSONObject: json, options: [])
        }
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                return parseJSON(json)
            } catch {
                return .failure(APIClientError.jsonParsingFailed(error: error))
            }
        }
    }
}

extension URLRequest {
    /// Convenience initializer that creates `URLRequest` with resource.
    ///
    /// - parameter resource:  Resource used for creating `URLRequest`.
    ///
    /// - returns: Initialized request.
    init<A>(baseURL: String, headers: [String : String], resource: Resource<A>) {
        var urlComponents = URLComponents(string: baseURL + resource.path)!
        urlComponents.queryItems = resource.params.map { return URLQueryItem(name: $0, value: $1) }
        self.init(url: urlComponents.url!)
        httpMethod = resource.method.method
        for (key, value) in headers {
            setValue(value, forHTTPHeaderField: key)
        }
        switch resource.method {
        case .post(let body), .put(let body):
            httpBody = body
        case .get: return
        }
    }
}

/// Use this class for loading data to/from API.
final class APIClient {

    let baseURL = "https://app.goclio.com/api/v2/"

    /// Calls `completion` after loading given resource.
    ///
    /// - parameter resource:   Resource to be loaded from API.
    /// - parameter completion: Called upon loading resource completion (called on main queue).
    func load<A>(resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        let headers = [ "Authorization" : "Bearer Xzd7LAtiZZ6HBBjx0DVRqalqN8yjvXgzY5qaD15a",
                        "Content-Type" : "application/json",
                        "Accept" : "application/json" ]
        let request = URLRequest(baseURL: baseURL, headers: headers, resource: resource)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    completion(resource.parse(data))
                    return
                }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.failure(APIClientError.unknownFailureReason))
            }
        }.resume()
    }
}
