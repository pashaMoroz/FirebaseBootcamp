//
//  RootContainerView.swift
//  NavigationSwiftUI
//
//  Created by Moroz Pavlo on 2023-03-06.
//

import SwiftUI

struct RootContainerView: View {
    
    @StateObject private var routes = Routes()
    
    var body: some View {
        
        TabView {
            profileView
            productView
            favoriteProductView
        }
    }
    
    
    var profileView: some View {
        ProfileView()
            .rootNavigationStack(for: Routes.HomeRootStack.self) { destination in
                switch destination {
                    
                case .settingsScreen:
                    SettingsView()
                }
            }
            .environmentObject(routes)
            .tabItem {
                Image(systemName: "person.fill")
            }
    }
    
    var productView: some View {
        NavigationStack {
            ProductsView()
        }
        .tabItem {
            Image(systemName: "cart.fill")
        }
    }
    
    var favoriteProductView: some View {
        NavigationStack {
            FavoriteView()
        }
        .tabItem {
            Image(systemName: "star.fill")
        }
    }
}
