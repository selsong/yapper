//
//  SettingsView.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("useDarkMode") private var useDarkMode = true
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Toggle("Dark Mode", isOn: $useDarkMode)
                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("AccentColor")))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
        })
    }
}
