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
        mapView.showsUserLocation = true
        
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays) // Remove old route overlays
        mapView.removeAnnotations(mapView.annotations) // Remove old annotations
        
       
        
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

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "CoffeeShopAnnotation")
            if let customImage = UIImage(named: "test") {
                let backgroundColor = UIColor.white
                let resizedAndRoundedImage = resizeImage(image: customImage, targetSize: CGSize(width: 30, height: 30), backgroundColor: backgroundColor)
                view.image = resizedAndRoundedImage
            }
            view.canShowCallout = true
            return view
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize, backgroundColor: UIColor) -> UIImage {
            let size = image.size
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            let context = UIGraphicsGetCurrentContext()!
            context.addEllipse(in: rect)
            context.clip()
            
            context.setFillColor(backgroundColor.cgColor)
            context.fill(rect)
            image.draw(in: rect)

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage!
        }
    }
}
