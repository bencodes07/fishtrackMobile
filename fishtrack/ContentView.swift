//
//  ContentView.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI
import SwiftData

class AppUserModel: ObservableObject {
    @Published var uid: String
    @Published var email: String?

    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }
}

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
                        Home(appUser: $appUser.user)
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
                Splash(appUser: $appUser.user)
            }
        }.onAppear {
            Task {
                do {
                    let user = try await AuthManager.shared.getCurrentSession()
                    appUser.user = AppUser(uid: user.uid, email: user.email)
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
