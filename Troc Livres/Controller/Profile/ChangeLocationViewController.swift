//
//  ChangeLocationViewController.swift
//  Troc Livres
//
//  Created by Guillaume Ramey on 20/06/2019.
//  Copyright © 2019 Guillaume Ramey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import ProgressHUD
import Firebase

protocol ChangeLocationDelegate {
    func changeLocation(address: String, location: CLLocation)
}

class ChangeLocationViewController: MapViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    var delegate: ChangeLocationDelegate?
    private var previousLocation: CLLocation?
    private var location: CLLocation!
    private var address: String? {
        didSet {
            activityIndicator.isHidden = address == "" ? false : true
            addressTextField.text = address
        }
    }
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed() {
        guard let address = address, let location = location else { return }
        ProgressHUD.show()
        DependencyInjection.shared.dataManager.setLocation(address: address, location: location) { error in
            if let error = error {
                ProgressHUD.showError("Impossible d'enregistrer l'adresse : " + error.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Adresse enregistrée")
            self.delegate?.changeLocation(address: address, location: location)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ChangeLocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        location = CLLocation(latitude: mapView.centerCoordinate.latitude,
                              longitude: mapView.centerCoordinate.longitude)

        // Don't change the value too often
        if let previousLocation = previousLocation {
            if location.distance(from: previousLocation) < 10 { return }
        }

        address = ""

        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                self.address = "Impossible d'obtenir l'adresse : " + error.localizedDescription
                return
            }
            guard let placemarks = placemarks?.first else {
                self.address = "Impossible d'obtenir l'adresse"
                return
            }

            let address = [placemarks.subThoroughfare ?? "", placemarks.thoroughfare ?? ""]
            self.address = address.filter { $0.isEmpty == false }.joined(separator: " ")
        }
    }
}
