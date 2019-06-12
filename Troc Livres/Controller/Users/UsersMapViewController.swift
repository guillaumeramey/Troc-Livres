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
        navigationController?.navigationBar.prefersLargeTitles = false
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
        var annotationView: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            imageView.sd_setImage(with: annotation.imageRef, placeholderImage: UIImage(named: "Image-User"))
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 5
            imageView.clipsToBounds = true

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
            let destinationVC = segue.destination as! UserTableViewController
            destinationVC.user = selectedUser
        }
    }
}
