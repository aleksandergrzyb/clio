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

enum APIClientError: Error {
    case jsonParsingFailed(error: Error)
    case unknownFailureReason
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
    /// - parameter f: Function that transforms body from one type to another (for `URLRequest` from dictionary to `Data`).
    ///
    /// - returns: Returns transformed `HttpMethod`.
    func transformBody<B>(f: (Body) -> B) -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let body):
            return .post(f(body))
        case .put(let body):
            return .put(f(body))
        }
    }
}

/// Encapsulate all information used to perform request for specified resource.
struct Resource<A> {

    /// Resource endpoint URL.
    let url: URL

    /// Method used for performing request.
    let method: HttpMethod<Data>

    /// Parse function that will transform data received from endpoint.
    let parse: (Data) -> Result<A>
}

extension Resource {

    /// Creates resource with given configuration.
    ///
    /// - parameter url:       URL for resource endpoint.
    /// - parameter method:    Method used for performing request (defaults to GET method).
    /// - parameter parseJSON: Parse function that will transform data received from endpoint.
    ///
    /// - returns: Resource with initialized configuration.
    init(url: URL, method: HttpMethod<AnyObject> = .get, parseJSON: @escaping (Any) -> Result<A>) {
        self.url = url
        self.method = method.transformBody { json in
            try! JSONSerialization.data(withJSONObject: json, options: [])
        }
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                return parseJSON(json)
            }
            catch {
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
    init<A>(resource: Resource<A>) {
        self.init(url: resource.url)
        httpMethod = resource.method.method
        switch resource.method {
        case .post(let body), .put(let body):
            httpBody = body
        case .get: return
        }
    }
}

final class APIClient {

    /// Calls `completion` after loading given resource.
    ///
    /// - parameter resource:   Resource to be loaded from API.
    /// - parameter completion: Called upon loading resource completion.
    func load<A>(resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        let request = URLRequest(resource: resource)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                completion(resource.parse(data))
            }
            if let error = error {
                completion(.failure(error))
            }
            completion(.failure(APIClientError.unknownFailureReason))
        }.resume()
    }
}
