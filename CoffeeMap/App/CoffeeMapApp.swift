//
//  CoffeeMapApp.swift
//  CoffeeMap
//
//  Created by Юлия Новикова on 18.03.2024.
//

import Foundation
import SwiftUI

@main
struct CoffeeMapApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = CoffeeMapViewModel()
            CoffeeMapView(viewModel: viewModel)
        }
    }
}
