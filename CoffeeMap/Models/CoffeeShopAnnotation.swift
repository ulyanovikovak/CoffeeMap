//
//  CoffeeShopAnnotation.swift
//
import Foundation
import MapKit

class CoffeeShopViewModel: Identifiable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
    @Published var destination: MKMapItem?

    init(name: String, location: CLLocationCoordinate2D) {
        self.name = name
        self.location = location
    }
}
