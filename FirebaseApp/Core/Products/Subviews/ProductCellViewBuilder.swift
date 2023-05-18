//
//  ProductCellViewBuilder.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-05-11.
//

import SwiftUI

struct ProductCellViewBuilder: View {
    
    @StateObject private var viewModel = FavoriteViewModel()
    @State private var product: Product? = nil
    let productId: String
    
    var body: some View {
        ZStack {
            if let product {
                ProductCellView(product: product)

            }
        }
        .task {
                product = try? await viewModel.productsManager.getProduct(productId: productId)
        }
    }
}

struct ProductCellViewBuilder_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellViewBuilder(productId: "1")
    }
}
