//
//  ContentView.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var tabSelected: Tab = .house
        
    init() {
        UITabBar.appearance().isHidden = true
    }
        
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $tabSelected) {
                    Home()
                        .tag(Tab.house)
                    AddFish()
                        .tag(Tab.plus)
                    Settings()
                        .tag(Tab.gearshape)
                }
            }
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $tabSelected)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
