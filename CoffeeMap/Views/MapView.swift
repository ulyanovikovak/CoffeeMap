//
//  MapView.swift
//  CoffeeMap
//
//  Created by Юлия Новикова on 18.03.2024.
//

import Foundation
import SwiftUI
import MapKit


struct MapView: UIViewRepresentable {
    var coffeeShops: [CoffeeShopViewModel]
    var userLocation: CLLocationCoordinate2D
    @Binding var selectedCoffeeShop: CoffeeShopViewModel?
    var route: MKRoute?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Set region to show user location and coffee shops
        let userRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(userRegion, animated: true)
        
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays) // Remove old route overlays
        mapView.removeAnnotations(mapView.annotations) // Remove old annotations
        
        // Add user annotation with custom icon
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "You"
        mapView.addAnnotation(userAnnotation)
        
        // Add coffee shop annotations
        coffeeShops.forEach { coffeeShop in
            let annotation = MKPointAnnotation()
            annotation.coordinate = coffeeShop.location
            annotation.title = coffeeShop.name
            mapView.addAnnotation(annotation)
        }

        if let route = route {
            mapView.addOverlay(route.polyline)
            
            // Adjust map region to show both user location and coffee shop
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        } else {
            // If no route, just show user location with default span
            let userRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(userRegion, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else {
                // Use custom image for user location
                let userAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
                userAnnotationView.image = UIImage(named: "user_pin")
                return userAnnotationView
            }
            
            let identifier = "CoffeeShopAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                // Customize annotation view for coffee shop
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                imageView.image = UIImage(named: "coffee_icon") // Set coffee shop icon
                annotationView?.leftCalloutAccessoryView = imageView
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else {
                return
            }
            
            let coffeeShop = parent.coffeeShops.first { $0.name == annotation.title }
            parent.selectedCoffeeShop = coffeeShop
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        }
    }
}
