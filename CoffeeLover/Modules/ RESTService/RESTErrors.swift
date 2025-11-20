//
//  RESTErrors.swift
//  REST-Service
//
//  Created by Danilo Henrique on 15/04/24.
//

import Foundation

enum RESTError: Error {
    case failedToCreateURL
    case failedToGenerateData
}

// MARK: - Error Descriptions

extension RESTError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToCreateURL:
            return "Failed to create URL"
        case .failedToGenerateData:
            return "Failed to generate a valid data"
        }
    }
}
