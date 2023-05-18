//
//  ProductsView.swift
//  FirebaseApp
//
//  Created by Moroz Pavlo on 2023-04-10.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ProductsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    @Published var isLoading: Bool = false
    private var lastDocument: DocumentSnapshot? = nil
    
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
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case priceHigh
        case priceLow
        
        var priceDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .priceHigh: return true
            case . priceLow: return false
            }
        }
    }
    
    enum CategoryOption: String, CaseIterable {
        case noCategory
        case smartphones
        case laptops
        case fragrances
        
        var categoryKey: String? {
            if self == .noCategory {
                return nil
            }
            return self.rawValue
        }
    }
    
    func filterSelected(option: FilterOption) async {
        self.selectedFilter = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
    }
    
    func categorySelected(option: CategoryOption) async {
        self.selectedCategory = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
        
    }
    
    func getProducts() {
        Task {
            isLoading = true
                let (newProducts, lastDocument) = try await productsManager.getAllProducts(priceDescending:
                                                                                            selectedFilter?.priceDescending, forCategory: selectedCategory?.categoryKey, count: 5, lastDocument: lastDocument)
                self.products.append(contentsOf: newProducts)
                if let lastDocument {
                    self.lastDocument = lastDocument
                    isLoading = false
                    print("DEBUG lastDocument is \(lastDocument)")
                } else {
                    print("DEBUG lastDocument is nil")
                }
        }
    }
    
    func addUserFavoriteProduct(productId: Int) {
        Task {
            let authDataResults = try authenticationManager.getAuthenticatedUser()
            try await userManager.addUserFavoriteProduct(userId: authDataResults.uid, productId: productId)
        }
    }
}

struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                    .contextMenu {
                        Button("Add to favorites") {
                            viewModel.addUserFavoriteProduct(productId: product.id)
                        }
                    }
                if product == viewModel.products.last && viewModel.isLoading == false {
                    ProgressView()
                        .onAppear {
                            viewModel.getProducts()
                        }
                }
            }
        }
        .navigationTitle("Products")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                               await viewModel.filterSelected(option: option)
                            }
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                               await viewModel.categorySelected(option: option)
                            }
                        }
                    }
                }
            }
        })
        .task {
             viewModel.getProducts()
        }
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductsView()
        }
    }
}
