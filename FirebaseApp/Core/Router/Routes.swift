//
//  Routes.swift
//  NavigationSwiftUI
//
//  Created by Moroz Pavlo on 2023-03-06.
//

import SwiftUI

class Routes: RoutesObject {
    
    enum HomeRootStack: Hashable {
        case settingsScreen
    }
    
    enum AuthenticationRootStack: Hashable {
        case signByEmail
    }
           
    @Published var isModalOnlyFullScreenCoverAuthenticationViewActive = false
    
}
