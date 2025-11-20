//
//  CoffeeAPI.swift
//  Canvas
//
//  Created by Danilo Henrique on 05/02/25.
//

import Foundation

enum CoffeeAPI {
    case getRandom
}

extension CoffeeAPI: RESTRequest {
    var baseURL: String {
        "https://coffee.alexflipnote.dev"
    }

    var path: String {
        switch self {
        case .getRandom:
            return "/random.json"
        }
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var httpMethod: HTTPMethod {
        .get
    }

    var HTTPHeaderFields: [String: String]? {
        nil
    }
}
