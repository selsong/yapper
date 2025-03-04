//
//  ContentView.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

import SwiftUI

// MARK: - Views
struct ContentView: View {
    @StateObject private var viewModel = FlashcardGameViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Text("Score: \(viewModel.score)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: {
                            // Reset score
                            viewModel.score = 0
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.top)
                    
                    Picker(selection: $viewModel.selectedDeckIndex, label: Text("Language")) {
                        ForEach(0..<viewModel.decks.count, id: \.self) { index in
                            Text("\(viewModel.decks[index].flagEmoji) \(viewModel.decks[index].language)")
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    FlashcardView(viewModel: viewModel)
                    
                    Spacer()
                    
                    ControlsView(viewModel: viewModel)
                }
            }
            .navigationBarTitle("Slang Flashcards", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
            )
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

struct FlashcardView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
                .frame(width: 300, height: 400)
            
            VStack(spacing: 20) {
                Text("\(viewModel.currentDeck.language) Slang")
                    .font(.headline)
                    .foregroundColor(Color("AccentColor"))
                
                if viewModel.isShowingAnswer {
                    Text(viewModel.currentCard.term)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Pronunciation: \(viewModel.currentCard.pronunciation)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(viewModel.currentCard.meaning)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Example: \(viewModel.currentCard.example)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if viewModel.showPronunciationFeedback {
                        Text(viewModel.pronunciationFeedback)
                            .font(.headline)
                            .foregroundColor(viewModel.pronunciationFeedback.contains("Great") ? .green : .orange)
                            .padding()
                    }
                } else {
                    Text(viewModel.currentCard.meaning)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Tap to reveal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if viewModel.isRecording {
                    Text("Listening...")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text(viewModel.pronunciationResult)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .frame(width: 300, height: 400)
            .onTapGesture {
                withAnimation {
                    viewModel.toggleAnswer()
                }
            }
        }
    }
}

struct ControlsView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 30) {
                Button(action: viewModel.previousCard) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                Button(action: viewModel.startRecording) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(viewModel.isRecording ? .red : .white)
                }
                
                Button(action: viewModel.nextCard) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
            Button(action: viewModel.markAsMastered) {
                Text("I know this!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
            }
            .opacity(viewModel.currentCard.mastered ? 0.5 : 1)
            .disabled(viewModel.currentCard.mastered)
        }
        .padding()
    }
}
