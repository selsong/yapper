//
//  yapperApp.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

// MARK: - YapperApp.swift
import SwiftUI
import FirebaseCore
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
@main
struct YapperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                RootView()
            }
            
//            ContentView()
//                .preferredColorScheme(.dark)
//                .accentColor(Color("AccentColor"))
        }
    }
}
