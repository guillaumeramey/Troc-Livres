//
//  MapViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 02/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    let mapRadius: CLLocationDistance = 2500

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }

    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            centerMapViewOnUserLocation()
        case .denied:
            alert(title: NSLocalizedString("error access location", comment: ""),
                  message: NSLocalizedString("change settings for access location", comment: ""))
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            alert(title: NSLocalizedString("error access location", comment: ""),
                  message: NSLocalizedString("access location restricted", comment: ""))
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    func centerMapViewOnUserLocation() {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: location,
                                             latitudinalMeters: mapRadius,
                                             longitudinalMeters: mapRadius)
        mapView.setRegion(region, animated: true)
    }
}
