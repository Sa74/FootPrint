//
//  URLSession+AnyPublisher.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation
import Combine

extension URLSession {
    func publisher<T: Decodable>(
        for url: URL,
        responseType: T.Type = T.self,
        decoder: JSONDecoder = .init()
    ) -> AnyPublisher<T, Error> {
        dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
