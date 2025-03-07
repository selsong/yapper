//
//  RootView.swift
//  yapper
//
//  Created by Selina Song on 3/6/25.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    
    var body: some View {
        NavigationStack {
            if showSignInView {
                // Show LoginView if not signed in
                LoginView()
            } else {
                // Show ContentView if signed in
                ContentView()
            }
        }
        .onAppear {
            // Check if the user is authenticated
            let authUser = try? AuthManager.shared.getAuthUser()
            self.showSignInView = authUser == nil
        }
    }
}

