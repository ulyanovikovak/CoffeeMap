//
//  CoffeeMapViewModel.swift
//  CoffeeMap
//
//  Created by Юлия Новикова on 18.03.2024.
//

import Foundation
import MapKit

class CoffeeMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coffeeShops: [CoffeeShopViewModel] = []
    @Published var selectedCoffeeShop: CoffeeShopViewModel?
    @Published var route: MKRoute?
    @Published var userLocation: CLLocationCoordinate2D?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        let regionRadius: CLLocationDistance = 5000
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        fetchCoffeeShops(in: region)
    }

    func fetchCoffeeShops(in region: MKCoordinateRegion) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "coffee"
        request.region = region
        let search = MKLocalSearch(request: request)

        search.start { [weak self] (response, error) in
            guard let self = self, let response = response else { return }
            self.coffeeShops = response.mapItems.map { CoffeeShopViewModel(name: $0.name ?? "", location: $0.placemark.coordinate) }
        }
    }

    func calculateRoute(to coffeeShop: CoffeeShopViewModel) {
        let destinationPlacemark = MKPlacemark(coordinate: coffeeShop.location)
        let destination = MKMapItem(placemark: destinationPlacemark)
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let response = response else { return }
            self.route = response.routes.first
            coffeeShop.destination = destination
        }
    }
}

