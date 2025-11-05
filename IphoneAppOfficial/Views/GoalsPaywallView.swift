//  GoalsPaywallView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/29/25.
//

//import SwiftUI
//import StoreKit
//
//struct GoalsPaywallView: View {
//    @ObservedObject var storeVM: StoreViewModel
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.colorScheme) var colorScheme
//    
//    // Example screenshots
//    let screenshotsDark = ["GoalsViewPreviewDark", "GoalTaskPreviewDark", "CompletedGoalDark"]
//    let screenshotsLight = ["GoalsViewPreviewLight", "GoalTaskPreviewLight", "CompletedGoalLight"]
//    var body: some View {
//        
//        VStack() {
//            ScrollView {
//                // MARK: Headline
//                Text("Unlock Goals")
//                    .font(.largeTitle)
//                    .bold()
//                
//                // MARK: Screenshots carousel
//                TabView {
//                    if colorScheme == .dark {
//                        ForEach(screenshotsDark, id: \.self) { imageName in
//                            Image(imageName)
//                                .resizable()
//                                .scaledToFit()
//                                .cornerRadius(16)
//                                .shadow(radius: 5)
//                                .padding()
//                        }
//                    } else {
//                        ForEach(screenshotsLight, id: \.self) { imageName in
//                            Image(imageName)
//                                .resizable()
//                                .scaledToFit()
//                                .cornerRadius(16)
//                                .shadow(radius: 5)
//                                .padding()
//                        }
//                    }
//                    
//                }
//                .tabViewStyle(.page(indexDisplayMode: .always))
//                .frame(height: 550)
//                
//                // MARK: Description / Value
//                Text("Track progress and organize tasks by a specific goal.  Tasks will automatically appear for the specified date scheduled in the daily tasks page and calendar.")
//                
//                
//                // MARK: Product Button
//            
//        }
//        .background(Color.black.opacity(0.4))
//            if let product = storeVM.products.first {
//                Button(action: {
//                    Task {
//                        await storeVM.purchaseGoals()
//                        if storeVM.isUnlocked {
//                            dismiss()
//                        }
//                    }
//                }) {
//                    Text("Unlock for \(product.displayPrice)")
//                        .bold()
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(.blue)
//                .padding(.horizontal)
//            } else {
//                ProgressView("Loading…")
//                    .padding()
//            }
//            
//            // MARK: Restore Purchases
//            Button("Restore Purchase") {
//                Task {
//                    await storeVM.restorePurchases()
//                }
//            }
//            .padding(.top, 10)
//            .font(.footnote)
//            
//            Spacer()
//            
//            // MARK: Close Button
//            Button("Cancel") {
//                dismiss()
//            }
//            .padding(.bottom)
//            .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .task {
//            await storeVM.fetchProducts()
//        }
//    }
//}
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

