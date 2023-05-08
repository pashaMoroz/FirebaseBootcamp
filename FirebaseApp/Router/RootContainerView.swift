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
        
        ProductsView()
            .rootNavigationStack(for: Routes.HomeRootStack.self) { destination in
                switch destination {

                case .settingsScreen:
                    SettingsView()
                }
            }
            .environmentObject(routes)
    }
}
