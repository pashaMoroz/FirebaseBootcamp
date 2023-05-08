//
//  SettingsView.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-03-16.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var routes: Routes
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        await router.pop($routes.isModalOnlyFullScreenCoverAuthenticationViewActive)
                        await router.pop(.toStackRoot)
                    } catch {
                        
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        await router.pop($routes.isModalOnlyFullScreenCoverAuthenticationViewActive)
                        await router.pop(.toStackRoot)
                    } catch {
                        
                    }
                }
            } label: {
                Text("Delete account")
            }

            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .navigationBarTitle("Settings")
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                    } catch {
                        
                    }
                }
            }
            
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("DEBUG: Password UPDATED!")
                    } catch {
                        
                    }
                }
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("DEBUG: Email UPDATED!")
                    } catch {
                        
                    }
                }
            }
        } header: {
            Text("Email function")
        }
        
    }
}

extension SettingsView {
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("DEBUG: Google LINKED!")
                    } catch {
                        
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("DEBUG: APPLE LINKED!")
                    } catch {
                        
                    }
                }
            }
            
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("DEBUG: Email LINKED!")
                    } catch {
                        
                    }
                }
            }
        } header: {
            Text("Create account")
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(Routes())
                .environmentObject(Router())
        }
    }
}
