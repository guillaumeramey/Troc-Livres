//
//  MapViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    let radius: CLLocationDistance = 15000
    var users: [User] = [User]()
    var selectedUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()

        mapView.delegate = self

        displayUsersOnMap()

    }

    private func displayUsersOnMap() {
        UserManager.getAllUsers(completion: { users in
            if let users = users {
//                let region = CLCircularRegion.init(center: self.userLocation, radius: self.radius, identifier: "userRegion")
//                self.users = users.filter { region.contains($0.coordinate) }
//                self.mapView.addAnnotations(self.users)
                self.mapView.addAnnotations(users)
            }
        })
    }

    // MARK: - User location

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }

    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            centerMapViewOnUserLocation()
        case .denied:
            alert(title: "Impossible d'accéder aux données de localisation", message: "Modifiez les paramètres de l'iPhone pour autoriser l'utilisation des données de localisation par l'application.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            alert(title: "Impossible d'accéder aux données de localisation", message: "Vous n'avez pas la permission suffisante pour utiliser les données de localisation.")
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }

    func centerMapViewOnLocation(_ location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: radius, longitudinalMeters: radius)
        userLocation = location
        mapView.setRegion(region, animated: true)
    }

    func centerMapViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            centerMapViewOnLocation(location)
        }
    }

    @IBAction func findMeButtonPressed(_ sender: AnyObject) {
        centerMapViewOnUserLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        centerMapViewOnLocation(userLocation)
//    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? User else { return nil }
        let identifier = "User"
        var annotationView: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            let reference = Constants.Firebase.imageRef.child("images/\(annotation.uid).jpg")
            let placeholderImage = UIImage(named: "placeholder.jpg")
            imageView.sd_setImage(with: reference, placeholderImage: placeholderImage)
            imageView.contentMode = .scaleAspectFit

            annotationView.leftCalloutAccessoryView = imageView
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let user = view.annotation as? User else { return }
        selectedUser = user
        performSegue(withIdentifier: "user", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "user" {
            let userVC = segue.destination as! UserViewController
            userVC.user = selectedUser
        }
    }
}
