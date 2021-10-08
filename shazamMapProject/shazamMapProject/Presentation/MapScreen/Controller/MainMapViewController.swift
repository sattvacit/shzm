//
//  MainMapViewController.swift
//  shazamMapProject
//
//  Created by Dmitriy Marchenkov on 08.10.2021.
//

import UIKit
import MapKit

final class MainMapViewController: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet private var mapView: MKMapView!
    
    // MARK: - Private Properties
    
    private let model = MainMapModel()
    private let locationService = ServiceLayer.locationService
    
    private var currentLocation: CLLocation? {
        didSet {
            searchInMap()
        }
    }
    
    
    private let searchRadius: CLLocationDistance = 2000
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserLocation()
    }
    
    // MARK: - Private Methods
    
    private func getUserLocation() {
        locationService.run { [weak self] localLocation in
            guard let self = self else { return }
            self.currentLocation = localLocation
            self.setupMap()
        }
    }
    
    private func setupMap() {
        mapView.delegate = self
        
        let coordinateRegion = MKCoordinateRegion.init(
            center: currentLocation!.coordinate,
            latitudinalMeters: searchRadius * 2.0,
            longitudinalMeters: searchRadius * 2.0
        )
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func searchInMap() {
        model.searchBars(in: currentLocation!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                for item in response!.mapItems {
                    let coordinate = item.placemark.location!.coordinate
                    self.addPinToMapView(title: item.name, location: coordinate)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func addPinToMapView(title: String?, location: CLLocationCoordinate2D) {
        if let title = title {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = title
            mapView.addAnnotation(annotation)
        }
    }
    
}

// MARK: - MKMapViewDelegate

extension MainMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocation = CLLocation(
            latitude: mapView.centerCoordinate.latitude,
            longitude: mapView.centerCoordinate.longitude
        )
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")
        annotationView.markerTintColor = .green
        return annotationView
    }
}
