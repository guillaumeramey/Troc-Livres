//
//  UsersMapViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 18/05/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import ProgressHUD

class UsersMapViewController: MapViewController {

    // MARK: - Properties
    
    var selectedUser: User!

    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        checkLocationServices()
        displayUsersOnMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func displayUsersOnMap() {
        ProgressHUD.show("Recherche d'utilisateurs")
        FirebaseManager.getUsers { users in
            ProgressHUD.dismiss()
            self.mapView.addAnnotations(users)
        }
    }

    @IBAction func findMeButtonPressed(_ sender: AnyObject) {
        centerMapViewOnUserLocation()
    }
}

extension UsersMapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension UsersMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? User else { return nil }
        let identifier = "User"
        var annotationView: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.animatesWhenAdded = true
            annotationView.clusteringIdentifier = identifier
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let user = view.annotation as? User else { return }
        selectedUser = user
        performSegue(withIdentifier: Constants.Segue.userVC, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.userVC {
            let destinationVC = segue.destination as! UserViewController
            destinationVC.user = selectedUser
        }
    }
}
