//
//  ActivityViewModelTests.swift
//  FootPrintTests
//
//  Created by Sasi Moorthy on 07.05.23.
//

import XCTest
@testable import FootPrint

final class ActivityViewModelTests: XCTestCase, NetworkProtocol, ActivityTrackingProtocol {

    private var flickrDownloader: FlickerPhotoDownloader!

    override func setUp() {
        super.setUp()

        flickrDownloader = FlickerPhotoDownloader(networkHandler: self)
    }

    override func tearDown() {
        flickrDownloader = nil
        super.tearDown()
    }

    // TODO: Add more tests for events triggered from `ActivityTrackingController` and Validate photo fetch calls!

    func testOnLoad() async throws {
        let activityViewModel = ActivityViewModel(
            photoDownloader: flickrDownloader,
            activityController: self
        )

        DispatchQueue.main.async {
            XCTAssertEqual(activityViewModel.state, .readyForActivity)
            XCTAssertEqual(activityViewModel.totalDistance, 0)
            XCTAssertEqual(activityViewModel.totalDuration, 0)
            XCTAssertTrue(activityViewModel.activityPhotos.isEmpty)
        }
    }

    func testActivityStart() async throws {
        let activityViewModel = ActivityViewModel(
            photoDownloader: flickrDownloader,
            activityController: self
        )

        Task {
            try await activityViewModel.handleAction(.didStartActivity)

            DispatchQueue.main.async {
                XCTAssertEqual(activityViewModel.state, .duringActivity)
                XCTAssertTrue(self.activityStarted)
                XCTAssertFalse(self.activityStopped)
            }
        }
    }

    func testActivityStartDuringActivity() async throws {
        let activityViewModel = ActivityViewModel(
            photoDownloader: flickrDownloader,
            activityController: self
        )

        try await activityViewModel.handleAction(.didStartActivity)

        var didFailWithError: Error?
        do {
            _ = try await activityViewModel.handleAction(.didStartActivity)
        } catch {
            didFailWithError = error
        }

        XCTAssertEqual(
            didFailWithError as? ActivityError,
            ActivityError.runtimeError("Invalid action didStartActivity for state duringActivity")
        )
    }

    func testActivityStop() async throws {
        let activityViewModel = ActivityViewModel(
            photoDownloader: flickrDownloader,
            activityController: self
        )

        Task {
            try await activityViewModel.handleAction(.didStopActivity)

            DispatchQueue.main.async {
                XCTAssertEqual(activityViewModel.state, .activityEnded)
                XCTAssertFalse(self.activityStarted)
                XCTAssertTrue(self.activityStopped)
            }
        }
    }

    func testActivityStopOnLoad() async throws {
        let activityViewModel = ActivityViewModel(
            photoDownloader: flickrDownloader,
            activityController: self
        )

        var didFailWithError: Error?
        do {
            _ = try await activityViewModel.handleAction(.didStopActivity)
        } catch {
            didFailWithError = error
        }

        XCTAssertEqual(
            didFailWithError as? ActivityError,
            ActivityError.runtimeError("Invalid action didStopActivity for state readyForActivity")
        )
    }

    // MARK: - NetworkProtocol methods

    func fetchData<T>(from url: URL) async throws -> T? where T : Decodable {
        return FlickerPhoto(id: "1", urlPath: "url") as? T
    }

    // MARK: - ActivityTrackingProtocol methods

    var activityStarted = false
    var activityStopped = false
    var didPerformEvent: ((FootPrint.ActivityTrackingController.Event) -> Void)?
    var error: Error?

    func startTrackingActivity() {
        activityStarted = true
        activityStopped = false
    }

    func stopTrackingActivity() {
        activityStarted = false
        activityStopped = true
    }

    func reset() {
        activityStarted = false
        activityStopped = false
    }
}
