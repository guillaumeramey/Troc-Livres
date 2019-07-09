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
            alert(title: "Impossible d'accéder aux données de localisation",
                  message: "Modifiez les paramètres de l'iPhone pour autoriser l'utilisation des données de localisation par l'application.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            alert(title: "Impossible d'accéder aux données de localisation",
                  message: "Vous n'avez pas la permission suffisante pour utiliser les données de localisation.")
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
