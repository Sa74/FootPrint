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

    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.flickr.com"
        components.path = "/services/rest/" + path
        components.queryItems = queryItems

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
            value: "33c7d9383079886ee5fe49f2e8bd52bb"
        )
    }
}
