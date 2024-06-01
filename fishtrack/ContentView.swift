//
//  ContentView.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI
import SwiftData

class AppUserWrapper: ObservableObject {
    @Published var user: AppUser?
}

struct ContentView: View {
    @State private var tabSelected: Tab = .house
    @StateObject var appUser = AppUserWrapper()
        
    var body: some View {
        ZStack {
            if let _ = appUser.user {
                VStack {
                    TabView(selection: $tabSelected) {
                        Home()
                            .tag(Tab.house)
                        AddFish()
                            .tag(Tab.plus)
                        Settings(appUser: $appUser.user)
                            .tag(Tab.gearshape)
                    }
                }
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $tabSelected)
                }
            } else {
                Settings(appUser: $appUser.user)
            }
        }.onAppear {
            Task {
                do {
                    let user = try await AuthManager.shared.getCurrentSession()
                    self.appUser.user = AppUser(uid: user.uid, email: user.email)
                } catch {
                    print("No current session found.")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
