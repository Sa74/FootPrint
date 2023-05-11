//
//  Endpoint.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation

struct Endpoint {
    var path: String
    var queryItems = [URLQueryItem]()
}

extension Endpoint {

    static let apiKey = "YOUR_FLICKR_API_KEY"

    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.flickr.com"
        components.path = "/services/rest/" + path
        components.queryItems = [Endpoint.apiKeyQueryItem] + queryItems

        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        return url
    }

    static var apiKeyQueryItem: URLQueryItem {
        URLQueryItem(
            name: "api_key",
            value: apiKey
        )
    }
}
