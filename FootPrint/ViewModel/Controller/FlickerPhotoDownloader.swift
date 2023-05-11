//
//  FlickerPhotoDownloader.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import CoreLocation
import Foundation

struct FlickerPhotoDownloader {

    private let networkHandler: NetworkProtocol

    init(networkHandler: NetworkProtocol = NetworkHandler()) {
        self.networkHandler = networkHandler
    }

    func fetchFlickerPhoto(
        latitude: Double,
        longitude: Double
    ) async throws -> FlickerPhoto? {
        return try await networkHandler.fetchData(
            from: Endpoint.search(
                latitude: latitude,
                longitude: longitude
            ).url
        )
    }
}

extension Endpoint {
    static func search(
        latitude: Double,
        longitude: Double,
        radiusInKm: Double = 0.05, // 50 Meter
        countPerPage: Int = 1
    ) -> Self {
        return Endpoint(
            path: "",
            queryItems: [
                URLQueryItem(name: "method", value: "flickr.photos.search"),
                URLQueryItem(name: "lat", value: "\(latitude)"),
                URLQueryItem(name: "lon", value: "\(longitude)"),
                URLQueryItem(name: "radius", value: "\(radiusInKm)"),
                URLQueryItem(name: "radius_units", value: "km"),
                URLQueryItem(name: "extras", value: "url_c"),
                URLQueryItem(name: "per_page", value: "\(countPerPage)"),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "nojsoncallback", value: "1")
            ]
        )
    }
}
