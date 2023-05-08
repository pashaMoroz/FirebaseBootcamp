//
//  ProfileView.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-03-31.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var isAuthenticationSuccess: Bool = false
    
    let authenticationManager: AuthenticationManager
    let userManager: UserManager
    
    init(authenticationManager: AuthenticationManager, userManager: UserManager) {
        self.authenticationManager = authenticationManager
        self.userManager = userManager
    }
    
    convenience init () {
        self.init(authenticationManager: AuthenticationManager(), userManager: UserManager())
    }
    
    func loadCurrentUser() async throws {
        let authDataResults = try authenticationManager.getAuthenticatedUser()
        self.user = try await userManager.getUser(userId: authDataResults.uid)
    }
    
    func checkAuthentication() -> Bool {
        let authUser = try? authenticationManager.getAuthenticatedUser()
        self.isAuthenticationSuccess = authUser == nil ? false : true
        return authUser == nil ? false : true
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        do {
            Task {
                try await userManager.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
                self.user = try await userManager.getUser(userId: user.userId)
            }
        }
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await userManager.addUserPreference(userId: user.userId, preference: text)
            self.user = try await userManager.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await userManager.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await userManager.getUser(userId: user.userId)
        }
    }
    
    func addFavoriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        Task {
            try await userManager.addFavoriteMovie(userId: user.userId, movie: movie)
            self.user = try await userManager.getUser(userId: user.userId)
        }
    }
    
    func removeFavoriteMovie() {
        guard let user else { return }
       
        Task {
            try await userManager.removeFavoriteMovie(userId: user.userId)
            self.user = try await userManager.getUser(userId: user.userId)
        }
    }

}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var routes: Routes
    
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }

    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId:\(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is Annonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { string in
                            Button(string) {
                                if preferenceIsSelected(text: string) {
                                    viewModel.removeUserPreference(text: string)
                                } else {
                                    viewModel.addUserPreference(text: string)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(text: string) ? .green : .red)
                        }
                    }
                    
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favoriteMovie == nil {
                        viewModel.addFavoriteMovie()
                    } else {
                        viewModel.removeFavoriteMovie()
                    }
                } label: {
                    Text("Favorite Movie: \((user.favoriteMovie?.title ?? ""))")
                }
            }
        }
        .onAppear {
            if !viewModel.checkAuthentication() {
                router.push($routes.isModalOnlyFullScreenCoverAuthenticationViewActive)
            } else {
                Task {
                    try? await viewModel.loadCurrentUser()
                }
            }
        }
        .fullScreenCover(isActive: $routes.isModalOnlyFullScreenCoverAuthenticationViewActive) {
            print("DEBUG: AuthenticationView onDismiss")
            Task {
                try? await viewModel.loadCurrentUser()
            }
        } content: {
            AuthenticationView()
                .rootNavigationStack(for: Routes.AuthenticationRootStack.self) { destination in
                    switch destination {
                        
                    case .signByEmail:
                        SignInEmailView()
                    }
                }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "gear")
                    .font(.headline)
                    .onTapGesture {
                        router.push(Routes.HomeRootStack.settingsScreen)
                    }
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(Routes())
                .environmentObject(Router())
        }
    }
}
