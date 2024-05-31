//
//  CustomTabBar.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case house
    case plus
    case gearshape
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    var tabColor: Color = .blue
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: Tab.house == selectedTab ? "house.fill" : "house")
                    .scaleEffect(Tab.house == selectedTab ? 1.25 : 1.0)
                    .foregroundColor(Tab.house == selectedTab ? tabColor : .gray)
                    .font(.system(size: 20))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = Tab.house
                        }
                    }
                Spacer()
                
                Spacer()
                Image(systemName: Tab.plus == selectedTab ? "plus" : "plus.circle")
                    .foregroundColor(Tab.plus == selectedTab ? .white : .gray)
                    .font(.system(size: Tab.plus == selectedTab ? 20 : 24))
                    .frame(width: 30, height: 30)
                    .background(Tab.plus == selectedTab ? .blue : .black.opacity(0))
                    .cornerRadius(100)
                    .scaleEffect(Tab.plus == selectedTab ? 1.25 : 1.0)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = Tab.plus
                        }
                    }
                Spacer()
                
                Spacer()
                Image(systemName: Tab.gearshape == selectedTab ? "gearshape.fill" : "gearshape")
                    .scaleEffect(Tab.gearshape == selectedTab ? 1.25 : 1.0)
                    .foregroundColor(Tab.gearshape == selectedTab ? tabColor : .gray)
                    .font(.system(size: 20))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = Tab.gearshape
                        }
                    }
                Spacer()
                
            }
            .frame(width: nil, height: 60)
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding()
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.house))
    }
}
