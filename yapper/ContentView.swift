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
    @State private var showOnboarding: Bool = true
    @State private var selectedDeck: LanguageDeck? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                if showOnboarding {
                    DeckSelectionView(viewModel: viewModel, showOnboarding: $showOnboarding, selectedDeck: $selectedDeck)
                    
                } else {
                    
                    VStack {
                        // Toast notification for pronunciation feedback
                        if viewModel.showPronunciationFeedback {
                            ToastView(message: viewModel.pronunciationFeedback, isSuccess: viewModel.pronunciationFeedback.contains("Great"))
                        }
                        
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
                        
                        DeckSelectorView(viewModel: viewModel)
                        
                        Spacer()
                        
                        FlashcardView(viewModel: viewModel)
                        
                        Spacer()
                        
                        ControlsView(viewModel: viewModel)
                    }
                }
            }
            .navigationBarTitle("Slang Flashcards", displayMode: .inline)
            .navigationBarItems(
                trailing:
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

// MARK: - Deck Selection Screen
struct DeckSelectionView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    @Binding var showOnboarding: Bool
    @Binding var selectedDeck: LanguageDeck?
    

    
    var body: some View {
        VStack {
            Text("Choose a Deck")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            ForEach(viewModel.decks) { deck in
                Button(action: {
                    selectedDeck = deck
                    viewModel.selectedDeckIndex = viewModel.decks.firstIndex(where: { $0.id == deck.id }) ?? 0
                    
                    showOnboarding = false
                }) {
                    HStack {
                        Text("\(deck.flagEmoji) \(deck.language)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                        
                        Spacer()
                        
                        Text("\(viewModel.masteredCardsCount(for: viewModel.decks.firstIndex(where: { $0.id == deck.id }) ?? 0))/\(deck.cards.count) Mastered")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color("BackgroundColor"))  // Navy blue background
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1.5)  // White outline
                    )
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
        }
        .transition(.opacity)
        .padding()
    }
}

// Separate DeckSelector into its own view
struct DeckSelectorView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedDeckIndex) {
            ForEach(0..<viewModel.decks.count, id: \.self) { index in
                VStack {
                    Text("\(viewModel.decks[index].flagEmoji) \(viewModel.decks[index].language)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.masteredCardsCount(for: index))/\(viewModel.decks[index].cards.count) Mastered")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                .tag(index)
            }
        }
        .padding(.top, 10)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 90)
        .background(Color("AccentColor").opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal)
//
    }
}


// Create a toast notification view
struct ToastView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isSuccess ? .green : .orange)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.7))
        )
        .padding(.top, 20)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(100)
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
                // Progress indicator
                HStack {
                    Text("\(viewModel.currentCardIndex + 1)/\(viewModel.currentDeck.cards.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    if viewModel.currentCard.mastered {
                        Label("Mastered", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal)
                
                Text("\(viewModel.currentDeck.language) Slang")
                    .font(.headline)
                    .foregroundColor(Color("FeatureColor"))
                
                if viewModel.isShowingAnswer {
                    Text(viewModel.currentCard.term)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("FeatureColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Pronunciation: \(viewModel.currentCard.pronunciation)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // ADD SPEAKER
                    Button(action: {
                            viewModel.speakPronunciation()  // Call the method to speak pronunciation
                        }) {
                            Image(systemName: "speaker.wave.2.fill")  // Use speaker icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                                    
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
                    
                } else {
                    Text(viewModel.currentCard.meaning)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("FeatureColor"))
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
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < 0 { // Swipe left (next card)
                            viewModel.nextCard()
                        }
                    }
            )
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
                
                // Make the microphone button more prominent
                Button(action: viewModel.startRecording) {
                    VStack {
                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(viewModel.isRecording ? .red : .green)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 60, height: 60)
                            )
                        
                        Text(viewModel.isRecording ? "Stop" : "Record")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: viewModel.nextCard) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
//            Button(action: viewModel.markAsMastered) {
//                Text("I know this!")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
//            }
//            .opacity(viewModel.currentCard.mastered ? 0.5 : 1)
//            .disabled(viewModel.currentCard.mastered)
        }
        .padding()
    }
}
