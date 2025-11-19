//  GoalsPaywallView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/29/25.

import SwiftUI
import StoreKit

struct ScreenshotPage: Identifiable {
    let id = UUID()
    let imageName: String
    let description: String
}

struct GoalsPaywallView: View {
    @ObservedObject var storeVM: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let screenshots: [ScreenshotPage] = [
        ScreenshotPage(imageName: "Goals", description: ""),
        ScreenshotPage(imageName: "FamiliarLayout", description: ""),
        ScreenshotPage(imageName: "GoalsAppearDTasks", description: "")
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Text("Unlock Goals")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.yellow.opacity(0.8))
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                        
                    
                }
                .frame(maxWidth: .infinity)
                
                ForEach(screenshots) { page in
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
//                        .padding()
                }
                HStack {
                    Text("Conquer Your Goals")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                        
                    
                }
                .frame(maxWidth: .infinity)
            }
            
            if storeVM.simulatePurchases {
                Button("Simulate Purchase") {
                    storeVM.simulatePurchase()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else if let product = storeVM.products.first {
                Button("Unlock for \(product.displayPrice)") {
                    Task {
                        await storeVM.purchaseGoals()
                        if storeVM.isUnlocked { dismiss() }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                ProgressView("Loading…")
                    .padding()
            }
            
            HStack {
                Spacer()
                // MARK: Restore Purchases
                Button("Restore Purchase") {
                    Task {
                        await storeVM.restorePurchases()
                    }
                }
//                .padding(.top, 10)
           
                Spacer()
                // MARK: Close Button
                Button("Cancel") {
                    dismiss()
                }
//                .padding(.bottom, 20)
                .foregroundColor(.gray)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .task {
            await storeVM.fetchProducts()
        }
    }
}

