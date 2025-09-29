//
//  GoalSortView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/22/25.
//


import SwiftUI

struct GoalSortView: View {
   
    @Binding var selectedSort: GoalSortOption
    

    var body: some View {
        Menu {
            ForEach(GoalSortOption.allCases) { option in
                Button(action: {
                   
                    selectedSort = option
                    
                    
                
                }) {
                    Text(option.rawValue).bold()
                }
            }
        } label: {
            Text("Sort")
                .padding(.trailing, 30)
                .padding(.top, 20)
        }
        .transaction { $0.disablesAnimations = true }
    }
}

struct CompletedGoalSortView: View {
   
    @Binding var selectedSort: CompletedGoalSortOption
    

    var body: some View {
        Menu {
            ForEach(CompletedGoalSortOption.allCases) { option in
                Button(action: {
                   
                    selectedSort = option
                    
                    
                
                }) {
                    Text(option.rawValue).bold()
                }
            }
        } label: {
            Text("Sort")
                .padding(.trailing, 30)
                .padding(.top, 20)
        }
        .transaction { $0.disablesAnimations = true }
    }
}

#Preview {

}
