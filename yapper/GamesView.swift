//
//  GamesView.swift
//  yapper
//
//  Games implementation for flashcard app
//

import SwiftUI
import CoreMotion

// Games View
struct GamesView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Games")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("Practice with \(viewModel.currentDeck.flagEmoji) \(viewModel.currentDeck.language)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                // Taboo Game Button
                NavigationLink(destination: TabooRulesView(viewModel: viewModel)) {
                    VStack(spacing: 15) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("Taboo")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Guess words without using forbidden clues")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 250, height: 180)
                    .background(Color("AccentColor").opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Games", displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Taboo Rules View
struct TabooRulesView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Text("How to Play Taboo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 15) {
                    RuleItem(
                        icon: "person.3.fill",
                        text: "Have someone hold the phone horizontally and guess the target word"
                    )
                    
                    RuleItem(
                        icon: "exclamationmark.triangle.fill",
                        text: "Don't use any of the forbidden words when giving clues"
                    )
                    
                    RuleItem(
                        icon: "phone.down.fill",
                        text: "Tilt phone DOWN when word is guessed correctly"
                    )
                    
                    RuleItem(
                        icon: "phone.arrow.up.right",
                        text: "Tilt phone UP to skip to next word"
                    )
                    
                    RuleItem(
                        icon: "clock.fill",
                        text: "You have 60 seconds per round"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(destination: TabooGameView(viewModel: viewModel)) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .navigationBarTitle("Rules", displayMode: .inline)
    }
}

//  Rule Item Component
struct RuleItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("AccentColor"))
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

//Taboo Game View
struct TabooGameView: View {
    @ObservedObject var viewModel: FlashcardGameViewModel
    @StateObject private var gameViewModel = TabooGameViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            if gameViewModel.gameState == .playing {
                TabooGamePlayingView(gameViewModel: gameViewModel)
            } else if gameViewModel.gameState == .finished {
                TabooGameSummaryView(gameViewModel: gameViewModel)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Lock to landscape orientation
            AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
            gameViewModel.startGame(with: viewModel.currentDeck.cards)
        }
        .onDisappear {
            // Reset orientation lock
            AppDelegate.orientationLock = UIInterfaceOrientationMask.all
            gameViewModel.stopGame()
        }
    }
}

// Taboo Game Playing View
struct TabooGamePlayingView: View {
    @ObservedObject var gameViewModel: TabooGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Target Word
                VStack {
                    Text("Target Word")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                    
                    Text(gameViewModel.currentCard?.term ?? "")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Timer
                    VStack {
                        Text("Time Left")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(gameViewModel.timeRemaining)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(gameViewModel.timeRemaining <= 10 ? .red : .white)
                    }
                    .padding(.bottom, 30)
                }
                .frame(width: geometry.size.width * 0.5)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2)
                
                // Right side - Taboo Words
                VStack {
                    Text("Forbidden Words")
                        .font(.headline)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(gameViewModel.tabooWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                
                                Text(word)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Score
                    VStack {
                        Text("Score")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(gameViewModel.score)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.bottom, 30)
                }
                .frame(width: geometry.size.width * 0.5)
            }
        }
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    
                    VStack {
                        Image(systemName: "phone.arrow.up.right")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Tilt UP to Skip")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                HStack {
                    VStack {
                        Image(systemName: "phone.down.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Tilt DOWN for Correct")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
            }
            .padding(),
            alignment: .topTrailing
        )
    }
}

// Taboo Game Summary View
struct TabooGameSummaryView: View {
    @ObservedObject var gameViewModel: TabooGameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(gameViewModel.score)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Words Guessed Correctly")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Games")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("AccentColor"))
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

// Taboo Game ViewModel
class TabooGameViewModel: ObservableObject {
    @Published var gameState: TabooGameState = .ready
    @Published var currentCard: SlangCard?
    @Published var tabooWords: [String] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    
    private var gameCards: [SlangCard] = []
    private var currentCardIndex: Int = 0
    private var gameTimer: Timer?
    private var motionManager = CMMotionManager()
    private var lastTiltTime: Date = Date()
    
    enum TabooGameState {
        case ready, playing, finished
    }
    
    func startGame(with cards: [SlangCard]) {
        print("🎮 Starting Taboo game with \(cards.count) cards")
        gameCards = cards.shuffled()
        currentCardIndex = 0
        score = 0
        timeRemaining = 60
        gameState = .playing
        
        loadNextCard()
        startTimer()
        startMotionDetection()
    }
    
    func stopGame() {
        print("🛑 Stopping Taboo game")
        gameTimer?.invalidate()
        motionManager.stopDeviceMotionUpdates()
        gameState = .finished
    }
    
    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                print("⏰ Time's up! Final score: \(self.score)")
                self.stopGame()
            }
        }
    }
    
    private func startMotionDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device motion not available")
            return
        }
        
        print("📱 Starting motion detection")
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            
            // For landscape orientation, use roll instead of pitch
            let roll = motion.attitude.roll
            
            // Add debouncing - only process tilts if enough time has passed
            let now = Date()
            guard now.timeIntervalSince(self.lastTiltTime) > 1.0 else { return }
            
            // Increased sensitivity thresholds - requires stronger tilt
            // Tilt down (towards floor) - Correct
            if roll < -1.6 {
                print("📱 Tilt DOWN detected - roll: \(roll)")
                self.lastTiltTime = now
                self.handleCorrect()
            }
            // Tilt up (towards ceiling) - Skip
            else if roll > 1.6 {
                print("📱 Tilt UP detected - roll: \(roll)")
                self.lastTiltTime = now
                self.handleSkip()
            }
        }
    }
    
    private func handleCorrect() {
        print("✅ CORRECT! Score before: \(score)")
        score += 1
        print("✅ CORRECT! Score after: \(score)")
        loadNextCard()
    }
    
    private func handleSkip() {
        print("⏭️ SKIP! Current word: \(currentCard?.term ?? "none")")
        loadNextCard()
    }
    
    private func loadNextCard() {
        if currentCardIndex >= gameCards.count {
            currentCardIndex = 0
            print("🔄 Reshuffling cards - back to start")
        }
            
        // Load the current card
        guard !gameCards.isEmpty else {
            print("❌ No cards available")
            return
        }
        
        currentCard = gameCards[currentCardIndex]
        print("📄 Loaded card \(currentCardIndex + 1): '\(currentCard?.term ?? "none")'")
        generateTabooWords()
        currentCardIndex += 1
    }
    
    private func generateTabooWords() {
        guard let card = currentCard else { return }
        
        // Extract words from the meaning and example to create taboo words
        let meaningWords = extractSignificantWords(from: card.meaning)
        let exampleWords = extractSignificantWords(from: card.example)
        let pronunciationWords = extractSignificantWords(from: card.pronunciation)
        
        var allPotentialWords = Set(meaningWords + exampleWords + pronunciationWords)
        
        // Remove the target word itself
        allPotentialWords.remove(card.term.lowercased())
        
        // Convert to array and take first 4, or pad with generic words if needed
        var tabooWordsArray = Array(allPotentialWords).prefix(4).map { $0.capitalized }
        
        // If we don't have enough words, add some generic ones
        let genericTabooWords = ["word", "thing", "say", "like", "use", "good", "bad", "very", "really", "just"]
        for genericWord in genericTabooWords {
            if tabooWordsArray.count < 4 && !tabooWordsArray.contains(genericWord.capitalized) {
                tabooWordsArray.append(genericWord.capitalized)
            }
        }
        
        tabooWords = Array(tabooWordsArray.prefix(4))
        print("🚫 Generated taboo words: \(tabooWords)")
    }
    
    private func extractSignificantWords(from text: String) -> [String] {
        let commonWords = Set(["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", "were", "be", "been", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "can", "may", "might", "this", "that", "these", "those", "i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them"])
        
        return text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { word in
                word.count > 2 && !commonWords.contains(word.lowercased())
            }
    }
}
