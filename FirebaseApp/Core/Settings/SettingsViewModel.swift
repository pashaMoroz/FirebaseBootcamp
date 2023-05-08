//
//  SettingsViewModel.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-03-16.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    let authenticationManager: AuthenticationManager
    let signInAppleHelper: SignInWithAppleHelper
    let signInWithGoogleHelper: SignInWithGoogleHelper
    
    init(authenticationManager: AuthenticationManager, signInAppleHelper: SignInWithAppleHelper, signInWithGoogleHelper: SignInWithGoogleHelper) {
        self.authenticationManager = authenticationManager
        self.signInWithGoogleHelper = signInWithGoogleHelper
        self.signInAppleHelper = signInAppleHelper
    }
    
    convenience init () {
        self.init(authenticationManager: AuthenticationManager(),
                  signInAppleHelper: SignInWithAppleHelper(),
                  signInWithGoogleHelper: SignInWithGoogleHelper())
    }
    
    func loadAuthUser() {
        self.authUser = try? authenticationManager.getAuthenticatedUser()
    }
    
    func loadAuthProviders() {
        if let providers = try? authenticationManager.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try authenticationManager.signOut()
    }
    
    func deleteAccount() async throws {
        try await authenticationManager.delete()
    }
    
    func resetPassword() async throws {
      let authUser = try authenticationManager.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
      try await authenticationManager.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
         
        let email = "hello1234@gmail.com"
        try await authenticationManager.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "Hello123!"
        try await authenticationManager.updatePassword(password: password)
    }
}

extension SettingsViewModel {
    
    func linkGoogleAccount() async throws {
        let tokens = try await signInWithGoogleHelper.signIn()
        self.authUser =  try await authenticationManager.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let tokens = try await signInAppleHelper.startSignInWithAppleFlow()
        self.authUser = try await authenticationManager.linkApple(tokens: tokens)
    }
    
    func linkEmailAccount() async throws {
        let email = "hello@gmail.com"
        let password = "123456a"
        self.authUser = try await authenticationManager.linkEmail(email: email, password: password)
    }
}
