//
//  yapperApp.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

// MARK: - YapperApp.swift
import SwiftUI

@main
struct YapperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .accentColor(Color("AccentColor"))
        }
    }
}
