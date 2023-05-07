//
//  NetworkHandler.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation
import Combine

protocol NetworkProtocol {
    func fetchData<T: Decodable>(from url: URL) async throws -> T?
}

final class NetworkHandler: NetworkProtocol {

    private let urlSession: URLSession
    var subscriptions = Set<AnyCancellable>()

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchData<T: Decodable>(from url: URL) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            urlSession.publisher(
                for: url,
                responseType: T.self,
                decoder: JSONDecoder()
            )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case .finished:
                        break
                    }
                }
            ) { model in
                continuation.resume(returning: model)
            }
            .store(in: &subscriptions)
        }
    }
}
