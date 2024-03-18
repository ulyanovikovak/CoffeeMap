//
//  CoffeeMapView.swift
//  CoffeeMap
//
//  Created by Юлия Новикова on 18.03.2024.
//

import Foundation
import SwiftUI


struct CoffeeMapView: View {
    @ObservedObject var viewModel: CoffeeMapViewModel

    var body: some View {
        VStack {
            if let userLocation = viewModel.userLocation {
                MapView(coffeeShops: viewModel.coffeeShops, userLocation: userLocation, selectedCoffeeShop: $viewModel.selectedCoffeeShop, route: viewModel.route)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .edgesIgnoringSafeArea(.top)
            }

            List(viewModel.coffeeShops) { coffeeShop in
                Text(coffeeShop.name)
                    .onTapGesture {
                        viewModel.selectedCoffeeShop = coffeeShop
                        viewModel.calculateRoute(to: coffeeShop)
                    }
            }
        }
    }
}

