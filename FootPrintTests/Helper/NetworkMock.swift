//
//  NetworkMock.swift
//  FootPrintTests
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation

@testable import FootPrint

final class NetworkingMock: NetworkProtocol {

    var result = Result<Decodable, Error>.success(Data())

    func fetchData<T: Decodable>(
        from url: URL
    ) async throws -> T? {
        try result.get() as? T
    }
}
