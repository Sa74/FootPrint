//
//  FlickerPhotoDownloaderTests.swift
//  FootPrintTests
//
//  Created by Sasi Moorthy on 07.05.23.
//

import XCTest
@testable import FootPrint

final class FlickerPhotoDownloaderTests: XCTestCase {

    private var networkHandler: NetworkingMock!
    private var photoDownloader: FlickerPhotoDownloader!
    private var testBundle: Bundle!

    override func setUp() {
        super.setUp()

        networkHandler = NetworkingMock()
        photoDownloader = FlickerPhotoDownloader(networkHandler: networkHandler)
        testBundle = Bundle(for: type(of: self))
    }

    override func tearDown() {
        networkHandler = nil
        photoDownloader = nil
        testBundle = nil
        super.tearDown()
    }

    // TODO: Add more tests for invalid / empty data parsing

    func testFetchFlickerPhoto() async throws {
        try makeResultMock(from: "flicker_mock_response.json")

        let flickrPhoto = try await photoDownloader.fetchFlickerPhoto(
            latitude: 48.30802583,
            longitude: 14.29024877
        )
        XCTAssertEqual(flickrPhoto?.id, "52857510483")
        XCTAssertEqual(flickrPhoto?.urlPath, "https://live.staticflickr.com/65535/52858607331_35f0e58f06_c.jpg")
    }

    private func makeResultMock(from filePath: String) throws {
        let data = try XCTUnwrap(testBundle.contentsOfFile(named: filePath))
        networkHandler.result = try .success(JSONDecoder().decode(FlickerPhoto.self, from: data))
    }
}
