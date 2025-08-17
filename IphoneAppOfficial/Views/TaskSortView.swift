//
//  TaskSortView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/3/25.
//

import SwiftUI

struct TaskSortMenu: View {
   
    @Binding var selectedSort: TaskSortOption
    

    var body: some View {
        Menu {
            ForEach(TaskSortOption.allCases) { option in
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
