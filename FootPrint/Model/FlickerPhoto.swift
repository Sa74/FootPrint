//
//  FlickerPhoto.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation

struct FlickerPhoto: Identifiable, Decodable, Equatable {
    let id: String
    let urlPath: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case urlPath = "url_c"
        case photos
        case photo
    }

    init(id: String,
         urlPath: String) {
        self.id = id
        self.urlPath = urlPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let photosContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .photos)
        var photoArrayContainer = try photosContainer.nestedUnkeyedContainer(forKey: .photo)

        // Decode the first photo in the array
        let photoContainer = try photoArrayContainer.nestedContainer(keyedBy: CodingKeys.self)
        id = try photoContainer.decode(String.self, forKey: .id)
        urlPath = try photoContainer.decode(String.self, forKey: .urlPath)
    }
}
