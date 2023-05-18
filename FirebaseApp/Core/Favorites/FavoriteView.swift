//
//  FavoriteView.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-05-10.
//

import SwiftUI

final class FavoriteViewModel: ObservableObject {
    @Published private(set) var userFavoriteProduct: [UserFavoriteProduct] = []

    let productsManager: ProductsManager
    let userManager: UserManager
    let authenticationManager: AuthenticationManager
    
    init(productsManager: ProductsManager, userManager: UserManager, authenticationManager: AuthenticationManager) {
        self.productsManager = productsManager
        self.userManager = userManager
        self.authenticationManager = authenticationManager
    }
    
    convenience init () {
        self.init(productsManager: ProductsManager(), userManager: UserManager(), authenticationManager: AuthenticationManager())
    }
    
    func addListenerForFavorites() {
        guard let authDataResult = try? authenticationManager.getAuthenticatedUser() else { return }
        userManager.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid) { [weak self] products in
            self?.userFavoriteProduct = products
        }
    }
//
//    @MainActor
//    func getFavorites() {
//        Task {
//            let authDataResult = try authenticationManager.getAuthenticatedUser()
//            self.userFavoriteProduct = try await userManager.getAllFavoriteProducts(userId: authDataResult.uid)
//        }
//    }
    
    func removeFromFavorites(favoriteProductId: String) {
        Task {
            let authDataResult = try authenticationManager.getAuthenticatedUser()
            try? await userManager.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favoriteProductId)
//            await getFavorites()
        }
    }
}


struct FavoriteView: View {
    @StateObject private var viewModel = FavoriteViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.userFavoriteProduct, id: \.id.self) { item in
                ProductCellViewBuilder(productId: String(item.productId))
                    .contextMenu {
                        Button("Remove from favorites") {
                            viewModel.removeFromFavorites(favoriteProductId: item.id)
                        }
                    }
                
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            //viewModel.getFavorites()
            viewModel.addListenerForFavorites()
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavoriteView()
        }
    }
}
