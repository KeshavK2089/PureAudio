//
//  StoreKitManager.swift
//  AudioPure
//
//  StoreKit 2 subscription management
//

import Foundation
import StoreKit
internal import Combine

/// Product identifiers for subscriptions (Monthly only)
enum ProductID: String, CaseIterable {
    // Monthly subscriptions only
    case basicMonthly = "com.pureaudio.basic.monthly"
    case proMonthly = "com.pureaudio.pro.monthly"
    case unlimitedMonthly = "com.pureaudio.unlimited.monthly"
    
    static var allProductIDs: [String] {
        allCases.map { $0.rawValue }
    }
    
    var tier: SubscriptionTier {
        switch self {
        case .basicMonthly: return .basic
        case .proMonthly: return .pro
        case .unlimitedMonthly: return .professional
        }
    }
}

@MainActor
class StoreKitManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    var currentSubscriptionTier: SubscriptionTier {
        // Check from highest to lowest tier (monthly only)
        if purchasedProductIDs.contains(ProductID.unlimitedMonthly.rawValue) {
            return .professional
        }
        if purchasedProductIDs.contains(ProductID.proMonthly.rawValue) {
            return .pro
        }
        if purchasedProductIDs.contains(ProductID.basicMonthly.rawValue) {
            return .basic
        }
        return .free
    }
    
    // MARK: - Private Properties
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Singleton
    
    static let shared = StoreKitManager()
    
    // MARK: - Initialization
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = ProductID.allProductIDs
            print("StoreKit: Requesting products with IDs: \(productIDs)")
            
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
            
            print("StoreKit: Successfully loaded \(products.count) products")
            for product in products {
                print("  - \(product.id): \(product.displayPrice)")
            }
            
            if products.isEmpty {
                // Products returned empty - this is expected before App Store review
                print("StoreKit: No products returned. Subscriptions may not be approved yet.")
                errorMessage = nil // Don't show as error, just informational
            }
        } catch {
            errorMessage = "StoreKit Error: \(error.localizedDescription)"
            print("StoreKit Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            errorMessage = "Purchase is pending approval"
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Handling
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.verifyAndHandle(result)
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    private func verifyAndHandle(_ result: VerificationResult<Transaction>) async throws -> Transaction {
        let transaction = try checkVerified(result)
        await updatePurchasedProducts()
        return transaction
    }
    
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        await MainActor.run {
            self.purchasedProductIDs = purchased
        }
    }
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helper Methods
    
    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }
    
    func monthlyProducts() -> [Product] {
        products.filter {
            $0.id.contains("monthly")
        }.sorted { $0.price < $1.price }
    }
}

// MARK: - Errors

enum StoreError: Error, LocalizedError {
    case failedVerification
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
