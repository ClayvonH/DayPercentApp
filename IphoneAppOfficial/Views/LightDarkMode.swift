//
//  LightDarkMode.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/27/25.
//
import SwiftUI
    
    struct LightDarkMode: View {
        @Binding var appearance: Appearance
        
        var body: some View {
            VStack {
                VStack (spacing: 20) {
                Text("Light Mode Dark Mode")
                    .font(.title)
                    .bold()
                    .padding(.top)
                    .padding(.bottom, 80)
               
                    ForEach(Appearance.allCases) { option in
                        Button {
                            appearance = option
                        } label: {
                            Label(option.rawValue.capitalized, systemImage: option.iconName)
                                .bold()
                                .font(.title)
                                .padding()
                        }
                    }
                }
            
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .transaction { $0.disablesAnimations = true } // prevents flicker
        }
    }


extension Appearance {
    var iconName: String {
        switch self {
        case .system: return "gearshape"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
//
//var body: some View {
//    Menu {
//        ForEach(TaskSortOption.allCases) { option in
//            Button(action: {
//               
//                selectedSort = option
//                
//                
//            
//            }) {
//                Text(option.rawValue).bold()
//            }
//        }
//    } label: {
//        Text("Sort")
//            .padding(.trailing, 30)
//            .padding(.top, 20)
//    }
//    .transaction { $0.disablesAnimations = true }
//}
