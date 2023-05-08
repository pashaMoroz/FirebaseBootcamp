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
    private var lastDocument: DocumentSnapshot? = nil
    
    let productsManager: ProductsManager
    
    init(productsManager: ProductsManager) {
        self.productsManager = productsManager
    }
    
    convenience init () {
        self.init(productsManager: ProductsManager())
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
        self.getProducts()
        
    }
    
    func getProducts() {
        Task {
            do {
                let (newProducts, lastDocument) = try await productsManager.getAllProducts(priceDescending:
                                                                                            selectedFilter?.priceDescending, forCategory: selectedCategory?.categoryKey, count: 10, lastDocument: lastDocument)
                self.products.append(contentsOf: newProducts)
                if let lastDocument {
                    self.lastDocument = lastDocument
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getProductsCount() {
        Task {
            let count = try await productsManager.getAllProductCount()
        }
    }

//    func getProductsByRating() {
//        Task {
//            do {
//                let (newProducts, lastDocument) = try await productsManager.getProductsByRating(cout: 3, lastDocument: lastDocument)
//                self.products.append(contentsOf: newProducts)
//                self.lastDocument = lastDocument
//            } catch {
//
//            }
//        }
//    }
}

struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        List {
            
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                
                if product == viewModel.products.last {
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
