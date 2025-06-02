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
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
@main
struct YapperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var loginViewModel = LoginViewModel()
        
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                RootView()
                    .environmentObject(loginViewModel)
            }
            
//            ContentView()
//                .preferredColorScheme(.dark)
//                .accentColor(Color("AccentColor"))
        }
    }
}
