//
//  LocationUtility.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-27.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

private let positionAuthStatus: [CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]

class LocationUtility: NSObject {

    static let shared = LocationUtility()

    let manager: CLLocationManager

    let permissionRequestResult = PassthroughSubject<Bool, Never>()
    //TODO: not good practice. Property wrapper cannot be in a protocol, so here I cannot create a protcol for LocationUtility
    // for creating a mock for dependency inject purpose. Change if have time.
    @Published private(set) var currentLocation: CLLocation?

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    var isPermissionGranted: Bool {
        return positionAuthStatus.contains(CLLocationManager.authorizationStatus())
    }

    var hasAskedPermission: Bool {
        return CLLocationManager.authorizationStatus() != .notDetermined
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingCurrentLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingCurrentLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationUtility: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            permissionRequestResult.send(true)
        case .denied, .restricted:
            permissionRequestResult.send(false)
        case .notDetermined:
            break
        @unknown default:
            permissionRequestResult.send(false)
        }
    }
}
