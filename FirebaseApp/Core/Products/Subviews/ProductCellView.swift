//
//  ProductCellView.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-04-10.
//

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width:75, height: 75)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title ?? "n/a")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("$" + String(product.price ?? 0))
                Text("Rating: " + String(product.rating ?? 0))
                Text("Category: " + (product.category ?? "n/a"))
                Text("Brand: " + (product.brand ?? "n/a"))
            }
            .font(.callout)
            .foregroundColor(.secondary)
        }
    }
}

struct ProductCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellView(product: Product(id: 1, title: "Test", description: "test", price: 100, discountPercentage: 2424, rating: 4242, stock: 4242, brand: "fwafwa", category: "fefes", thumbnail: "fefefs", images: ["fefes"]))
    }
}
