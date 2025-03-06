//
//  SettingsView.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject{
    func signOut() throws{
        try AuthManager.shared.signOut()
        
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List{
            Button("Log out"){
                Task{
                    do{
                        try viewModel.signOut()
                        showSignInView = true
                    }catch{
                        print(error)
                        
                    }
                }
                
            }
        }
        .navigationBarTitle("Settings")
        
//        ZStack {
//            Color("BackgroundColor")
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Settings")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                
//                
//                Spacer()
//                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Close")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("AccentColor")))
//                        .frame(maxWidth: .infinity)
//                }
//            }
//            .padding()
//        }
//        .navigationBarTitle("Settings", displayMode: .inline)
//        .navigationBarItems(leading: Button(action: {
//            presentationMode.wrappedValue.dismiss()
//        }) {
//            Image(systemName: "xmark")
//                .foregroundColor(.white)
//        })
   }
}
