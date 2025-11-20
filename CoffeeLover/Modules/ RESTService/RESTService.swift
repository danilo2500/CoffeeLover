//
//  RESTService.swift
//  REST-Service
//
//  Created by Danilo Henrique on 15/04/24.
//

import Foundation

class RESTService<T: RESTRequest> {
    // MARK: - Public Functions

    func request<U: Decodable>(_ request: T, completion: @escaping (Result<U, Error>) -> Void) {
        let urlRequest: URLRequest
        do {
            urlRequest = try createURLRequest(with: request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let object = try JSONDecoder().decode(U.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error ?? RESTError.failedToGenerateData))
                }
            }
        }.resume()
    }

    // MARK: - Private Functions

    private func createURLRequest(with request: T) throws -> URLRequest {
        let url: URL
        do {
            url = try createURL(with: request)
        } catch {
            throw error
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = request.HTTPHeaderFields
        return urlRequest
    }

    private func createURL(with request: T) throws -> URL {
        var urlComponents = URLComponents(string: request.baseURL)
        urlComponents?.path = request.path
        urlComponents?.queryItems = request.queryItems

        if let url = urlComponents?.url {
            return url
        } else {
            throw RESTError.failedToCreateURL
        }
    }
}
