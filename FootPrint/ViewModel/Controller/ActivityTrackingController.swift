//
//  ActivityTrackingController.swift
//  FootPrint
//
//  Created by Sasi Moorthy on 07.05.23.
//

import Foundation
import CoreLocation

protocol ActivityTrackingProtocol {
    var error: Error? { get }
    var didPerformEvent: ((ActivityTrackingController.Event) -> Void)? { get set }

    func startTrackingActivity()
    func stopTrackingActivity()
    func reset()
}

final class ActivityTrackingController: NSObject, CLLocationManagerDelegate, ActivityTrackingProtocol {

    enum Event {
        case didUpdateValues(distance: Double, duration: TimeInterval)
        case didCrossMinimumDistance(coordinate: CLLocationCoordinate2D)
        case didFailWithError(Error)
        case didExceedTimeLimit
    }

    private let locationManager: CLLocationManager
    private var lastLocation: CLLocation?
    private let distanceFilter: Double
    private let trackingDuration: TimeInterval

    private var currentIntervalDistance: Double = 0
    private var isTrackingActivity = false
    private var startDate: Date?
    private(set) var error: Error?

    var didPerformEvent: ((Event) -> Void)?

    private var totalDistance: Double = 0 {
        didSet {
            performEvent(
                .didUpdateValues(
                    distance: totalDistance,
                    duration: totalDuration
                )
            )
        }
    }

    private var totalDuration: TimeInterval = 0 {
        didSet {
            performEvent(
                .didUpdateValues(
                    distance: totalDistance,
                    duration: totalDuration
                )
            )
        }
    }

    init(
        locationManager: CLLocationManager = CLLocationManager(),
        lastLocation: CLLocation? = nil,
        distanceFilter: Double = 100, // 100 Meters
        trackingDuration: TimeInterval = 7200 // 120 Minutes
    ) {
        self.locationManager = locationManager
        self.lastLocation = lastLocation
        self.distanceFilter = distanceFilter
        self.trackingDuration = trackingDuration

        super.init()

        setupLocationManager()
    }

    // MARK: - ActivityTrackingProtocol methods

    func startTrackingActivity() {
        guard !isTrackingActivity else {
            return
        }

        reset()
        startDate = Date()
        isTrackingActivity = true
        switch locationManager.authorizationStatus {
        case .notDetermined,
                .denied,
                .restricted:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse,
                .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            stopTrackingActivity()
        }
    }

    func stopTrackingActivity() {
        isTrackingActivity = false
        locationManager.stopUpdatingLocation()
    }

    func reset() {
        guard !isTrackingActivity else {
            return
        }
        totalDistance = 0
        totalDuration = 0
        currentIntervalDistance = 0
        lastLocation = nil
        startDate = nil
        error = nil
    }

    // MARK: - CLLocationManagerDelegate methods

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .authorizedAlways,
                .authorizedWhenInUse:
            if isTrackingActivity {
                locationManager.startUpdatingLocation()
            }
        default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let currentLocation = locations.last,
              let startDate = startDate else {
            return
        }

        totalDuration = currentLocation.timestamp.timeIntervalSince(startDate)
        guard totalDuration <= trackingDuration else {
            performEvent(.didExceedTimeLimit)
            return
        }

        guard let distance = lastLocation?.distance(from: currentLocation) else {
            lastLocation = currentLocation
            return
        }

        currentIntervalDistance += distance
        if currentIntervalDistance >= distanceFilter {
            performEvent(
                .didCrossMinimumDistance(
                    coordinate: currentLocation.coordinate
                )
            )
            currentIntervalDistance = max(currentIntervalDistance - distanceFilter, 0)
        }

        totalDistance += distance
        lastLocation = currentLocation
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        self.error = error
        performEvent(.didFailWithError(error))
    }

    // MARK: - Private methods

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
    }

    private func performEvent(_ event: Event) {
        switch event {
        case .didExceedTimeLimit,
                .didFailWithError:
            stopTrackingActivity()
        default:
            break
        }
        didPerformEvent?(event)
    }
}
