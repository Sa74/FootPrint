//
//  LocationManagerMock.swift
//  FootPrintTests
//
//  Created by Sasi Moorthy on 07.05.23.
//

import CoreLocation

// TODO: Mock data creation and delegate calls
final class LocationManagerMock: CLLocationManager {

    var receivedAutorizeRequest = false
    var status: CLAuthorizationStatus = .notDetermined

    override var authorizationStatus: CLAuthorizationStatus {
        return status
    }

    override func requestWhenInUseAuthorization() {
        receivedAutorizeRequest = true
    }

    override func requestAlwaysAuthorization() {
        receivedAutorizeRequest = true
    }

    override func startUpdatingLocation() {
        // Do nothing
    }

    func updateLocation(location: CLLocation) {
        delegate?.locationManager?(
            self,
            didUpdateLocations: [location]
        )
    }
}
