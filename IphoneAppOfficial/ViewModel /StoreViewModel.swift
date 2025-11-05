//
//  StoreViewModel.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/29/25.
//
import SwiftUI
import StoreKit
import Foundation
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    
    @AppStorage("isUnlocked") private var storedUnlocked: Bool = false {
        didSet {
            if isUnlocked != storedUnlocked {
                isUnlocked = storedUnlocked
            }
        }
    }

    @Published var isUnlocked: Bool = false {
        didSet {
            if storedUnlocked != isUnlocked {
                storedUnlocked = isUnlocked
            }
        }
    }

    
    @Published var products: [Product] = []
    
    private let goalsProductID = "goalsunlock"
    
    /// Toggle this to true while testing on simulator
    var simulatePurchases = false
    
    init(simulate: Bool = false) {
        self.simulatePurchases = simulate
        Task {
            updates = listenForTransactions()
            if simulatePurchases {
                // Skip real fetch in simulation mode
                products = []
            } else {
                await fetchProducts()
                await checkOwnership() // ✅ <-- Add this
      
//                await checkOwnership()
            }
        }
    }
    
    func fetchProducts() async {
        guard !simulatePurchases else { return }
        do {
            products = try await Product.products(for: [goalsProductID])
            print("Fetched products fromm store: \(products)")
        } catch {
            print("Failed to fetch products: \(error)")
        }
        
    }
    
    func purchaseGoals() async {
        if simulatePurchases {
            isUnlocked = true
            print("Simulated purchase complete")
            return
        }
        
        guard let product = products.first else { return }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                if transaction.productID == goalsProductID {
                    isUnlocked = true
                }
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    func restorePurchases() async {
        if simulatePurchases {
            isUnlocked = true
            print("Simulated restore complete")
            return
        }
        
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                if transaction.productID == goalsProductID,
                   transaction.revocationDate == nil {
                    isUnlocked = true
                    break
                }
            }
        } catch {
            print("Restore failed: \(error)")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    func simulatePurchase() {
        isUnlocked = true
        print("Simulated purchase triggered")
    }
    
    func checkOwnership() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == goalsProductID {
                    isUnlocked = true
                    print("✅ Ownership confirmed for \(transaction.productID)")
                    return
                }
            } catch {
                print("Ownership check failed: \(error)")
            }
        }
        print("⚠️ No ownership found for \(goalsProductID)")
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    if transaction.productID == self.goalsProductID {
                        await MainActor.run {
                            self.isUnlocked = true
                        }
                    }
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }


    
    private var updates: Task<Void, Never>? = nil
}
