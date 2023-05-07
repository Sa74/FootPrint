//
//  ActivityTrackingControllerTests.swift
//  FootPrintTests
//
//  Created by Sasi Moorthy on 07.05.23.
//

import CoreLocation
import XCTest
@testable import FootPrint

final class ActivityTrackingControllerTests: XCTestCase {

    private var locationManagerMock: LocationManagerMock!

    override func setUp() {
        super.setUp()

        locationManagerMock = LocationManagerMock()
    }

    override func tearDown() {
        locationManagerMock = nil
        super.tearDown()
    }

    // TODO: Add more tests for change in location permission, event trigger for distance change and time limit exceed!

    func testOnLoad() async throws {
        let activityController = ActivityTrackingController(
            locationManager: locationManagerMock
        )
        activityController.didPerformEvent = { _ in }

        XCTAssertNil(activityController.error)
        XCTAssertFalse(locationManagerMock.receivedAutorizeRequest)
    }

    func testStartTrackingActivityOnLoad() async throws {
        let activityController = ActivityTrackingController(
            locationManager: locationManagerMock
        )
        activityController.didPerformEvent = { _ in }

        activityController.startTrackingActivity()
        XCTAssertTrue(locationManagerMock.receivedAutorizeRequest)
    }

    func testDidCrossDistanceEventDuringActivity() async throws {
        var receivedCoordinate: CLLocationCoordinate2D?
        let activityController = ActivityTrackingController(
            locationManager: locationManagerMock,
            distanceFilter: 20
        )
        activityController.didPerformEvent = { event in
            switch event {
            case let .didCrossMinimumDistance(coordinate):
                receivedCoordinate = coordinate
            default:
                break
            }
        }

        locationManagerMock.status = .authorizedAlways
        activityController.startTrackingActivity()

        let locations = mockLocationCoordinates()
        locations.forEach { location in
            locationManagerMock.updateLocation(
                location: location
            )
        }

        XCTAssertEqual(receivedCoordinate?.latitude, 48.30809576)
        XCTAssertEqual(receivedCoordinate?.longitude, 14.28992581)
    }

    func testDidUpdateValuesEventDuringActivity() async throws {
        var totalDistance: Double = 0
        let activityController = ActivityTrackingController(
            locationManager: locationManagerMock
        )
        activityController.didPerformEvent = { event in
            switch event {
            case let .didUpdateValues(distance, _):
                totalDistance = distance
            default:
                break
            }
        }

        locationManagerMock.status = .authorizedAlways
        activityController.startTrackingActivity()

        let locations = mockLocationCoordinates()
        locations.forEach { location in
            locationManagerMock.updateLocation(
                location: location
            )
        }

        XCTAssertEqual(totalDistance, 20.59889567098156)
    }

    func testDidExceedTimeLimitEventDuringActivity() async throws {
        var didExceedTimeLimit = false
        let activityController = ActivityTrackingController(
            locationManager: locationManagerMock,
            trackingDuration: 1
        )
        activityController.didPerformEvent = { event in
            switch event {
            case .didExceedTimeLimit:
                didExceedTimeLimit = true
            default:
                break
            }
        }

        locationManagerMock.status = .authorizedAlways
        activityController.startTrackingActivity()

        sleep(2)
        let locations = mockLocationCoordinates()
        locations.forEach { location in
            locationManagerMock.updateLocation(
                location: location
            )
        }

        XCTAssertTrue(didExceedTimeLimit)
    }

    private func mockLocationCoordinates() -> [CLLocation] {
        return [CLLocation(
            latitude: 48.30824397,
            longitude: 14.29009240
        ),
         CLLocation(
            latitude: 48.30809576,
            longitude: 14.28992581
         )]
    }
}
