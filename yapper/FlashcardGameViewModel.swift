//
//  FlashcardGameViewModel.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

import Foundation
import SwiftUI
import AVFoundation
import Speech
import Combine
import Firebase

// MARK: - View Models
class FlashcardGameViewModel: ObservableObject {
    @Published var decks: [LanguageDeck]
    @Published var selectedDeckIndex: Int = 0
    @Published var currentCardIndex: Int = 0
    @Published var isShowingAnswer: Bool = false
    @Published var score: Int = 0
    @Published var isRecording: Bool = false
    @Published var pronunciationResult: String = ""
    @Published var pronunciationFeedback: String = ""
    @Published var showPronunciationFeedback: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var username: String = ""
    @Published var selectedTranslationLanguage: TranslationLanguage = .english
        
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var cancellables = Set<AnyCancellable>()
    private var autoAdvanceTimer: Timer?

    enum TranslationLanguage: String, CaseIterable {
        case english = "English"
        case korean = "Korean"
        case chinese = "Chinese"
        case spanish = "Spanish"
    }
    init() {
        // Initialize with sample data
        self.decks = [
            LanguageDeck(
                language: "Korean",
                flagEmoji: "🇰🇷",
                cards: [
                    SlangCard(term: "괜찮아", pronunciation: "Gwenchana", meaning: "I am okay, It's going to be okay", example: "괜찮아, 걱정마! (It's okay, don't worry!)"),
                    SlangCard(term: "대박", pronunciation: "Daebak", meaning: "Wow! Excitement and Pleased", example: "대박! 너무 좋아! (Wow! That's so good!)"),
                    SlangCard(term: "귀여워요", pronunciation: "Gwiyeowo", meaning: "Something that's incredibly cute", example: "이 강아지는 정말 귀여워요! (This puppy is really cute!)"),
                    SlangCard(term: "아싸", pronunciation: "Ah-ssa", meaning: "Yay! Use it in celebration", example: "아싸! 우리가 이겼어! (Yay! We won!)"),
                    SlangCard(term: "화이팅", pronunciation: "Hwaiting", meaning: "Good luck! Fight on!", example: "시험 화이팅! (Good luck on your exam!)"),
                    SlangCard(term: "심쿵", pronunciation: "Simkung", meaning: "Heart throb/ Big Crush", example: "그 배우 보고 심쿵했어 (I had a heart throb when I saw that actor)"),
                    SlangCard(term: "헐", pronunciation: "Heol", meaning: "OMG! Very surprising moment", example: "헐! 정말? (OMG! Really?)"),
                    SlangCard(term: "짱", pronunciation: "Jjang", meaning: "The best", example: "너 정말 짱이야! (You're the best!)"),
                    SlangCard(term: "대박사건", pronunciation: "Daebak-sageon", meaning: "Big deal/huge event", example: "어제 대박사건이 있었어 (There was a huge event yesterday)"),
                    SlangCard(term: "억울해", pronunciation: "Eok-ul-hae", meaning: "It's unfair/I feel wronged", example: "정말 억울해! (It's so unfair!)")
                ]),
            LanguageDeck(
                language: "Chinese",
                flagEmoji: "🇨🇳",
                cards: [
                    SlangCard(term: "牛", pronunciation: "niú", meaning: "Awesome, super cool", example: "你真牛! (You're so awesome!)"),
                    SlangCard(term: "哥们儿", pronunciation: "gēmenr", meaning: "Dude, Bro", example: "哥们儿，你去哪里? (Dude, where are you going?)"),
                    SlangCard(term: "啥", pronunciation: "shá", meaning: "What?", example: "Same as 什么 (shén me)"),
                    SlangCard(term: "哇塞", pronunciation: "wāsài", meaning: "Wow", example: "哇塞! 这太棒了! (Wow! This is great!)"),
                    SlangCard(term: "酷", pronunciation: "kù", meaning: "Cool", example: "这很酷! (That's cool!)"),
                    SlangCard(term: "六", pronunciation: "liù", meaning: "Awesome skills, good job", example: "Often used in gaming context, 666"),
                    SlangCard(term: "放鸽子", pronunciation: "fàng gēzi", meaning: "To stand somebody up", example: "他又放鸽子了! (He stood me up again!)"),
                    SlangCard(term: "摆烂", pronunciation: "bǎi làn", meaning: "Give up", example: "Context: give up and lay down"),
                    SlangCard(term: "有一说一", pronunciation: "yǒu yī shuō yī", meaning: "TBH (To be honest)", example: "Abbreviated as u1s1"),
                    SlangCard(term: "懂得都懂", pronunciation: "dǒng de dōu dǒng", meaning: "If you know, you know", example: "Abbreviated as dddd"),
                    SlangCard(term: "永远的神", pronunciation: "yǒngyuǎn de shén", meaning: "GOAT (Greatest Of All Time)", example: "Abbreviated as yyds"),
                    SlangCard(term: "i人 / e人", pronunciation: "i rén / e rén", meaning: "Introvert / Extrovert", example: "Based on MBTI personality test"),
                    SlangCard(term: "女神 / 男神", pronunciation: "nǚ shén / nán shén", meaning: "Celebrity crush", example: "Person you think is incredibly attractive"),
                    SlangCard(term: "太油了", pronunciation: "tài yóu le", meaning: "Greasy", example: "Reference to unkempt middle-aged men"),
                    SlangCard(term: "笔芯", pronunciation: "bǐ xīn", meaning: "Love you", example: "A cute way of saying 'love you' (sounds like 'bless you')"),
                    SlangCard(term: "太可了", pronunciation: "tài kě le", meaning: "Super cute", example: "This outfit is 太可了!"),
                    SlangCard(term: "绝绝子", pronunciation: "jué jué zi", meaning: "Absolutely amazing", example: "This restaurant is 绝绝子!"),
                    SlangCard(term: "无缘无故", pronunciation: "wú yuán wú gù", meaning: "for no reason", example: "Why are you 无缘无故 (ignoring me) 不理我 ?")
                ]),
            
            LanguageDeck(
                language: "Spanish",
                flagEmoji: "🇪🇸",
                cards: [
                    SlangCard(
                        term: "Genial",
                        pronunciation: "Heh-nee-al",
                        meaning: "Cool, awesome, great",
                        example: "Ese concierto fue genial. (That concert was awesome.)"
                    ),
                    SlangCard(term: "Chido", pronunciation: "Chee-do", meaning: "Cool (Mexico)", example: "Esa canción está bien chida. (That song is really cool.)"),
                    SlangCard(term: "Vale", pronunciation: "Bah-leh", meaning: "Okay, got it (Spain)", example: "Vale, nos vemos a las ocho. (Okay, see you at eight.)"),
                    SlangCard(term: "No mames", pronunciation: "No mah-mehs", meaning: "No way! (Mexico)", example: "¡No mames! ¿En serio? (No way! Seriously?)"),
                    SlangCard(term: "Flipar", pronunciation: "Flee-par", meaning: "Freak out, be amazed (Spain)", example: "Vas a flipar con esta película. (You're going to freak out with this movie.)"),
                    SlangCard(term: "Chamba", pronunciation: "Chahm-bah", meaning: "Job, work (Latin America)", example: "Tengo mucha chamba hoy. (I have a lot of work today.)"),
                    SlangCard(term: "Estar en la luna", pronunciation: "Es-tar en la loo-nah", meaning: "To be spaced out", example: "Hoy en clase estaba en la luna. (I was spaced out in class today.)"),
                    SlangCard(term: "Pana", pronunciation: "Pah-nah", meaning: "Friend, buddy (Venezuela)", example: "Ese pana siempre me ayuda. (That buddy always helps me.)"),
                    SlangCard(term: "Hacer la vista gorda", pronunciation: "Ah-ser lah vees-tah gor-dah", meaning: "Turn a blind eye", example: "El profe hizo la vista gorda con la tarea. (The teacher turned a blind eye to the homework.)")
                ]),
            LanguageDeck(
                language: "English",
                flagEmoji: "🇺🇸",
                cards: [
                    SlangCard(
                        term: "Yapper",
                        pronunciation: "yap-er",
                        meaning: "person who talks a lot",
                        example: "Stop yapping and get to work!",
                        translations: [
                            "Korean": "마구 떠들다 / 수다쟁이",
                            "Chinese": "说个不停 / 话多的人",
                            "Spanish": "Persona habladora"
                        ]
                    ),
                    SlangCard(
                        term: "Slay",
                        pronunciation: "slay",
                        meaning: "To do something exceptionally well",
                        example: "Her presentation absolutely slayed!",
                        translations: [
                            "Korean": "완전 멋지게 해내다",
                            "Chinese": "太棒了",
                            "Spanish": "Arrasar, hacerlo increíblemente bien"
                        ]
                    ),
                    SlangCard(
                        term: "Cooked",
                        pronunciation: "cooked",
                        meaning: "Exhausted, burnt out, or in a bad situation",
                        example: "After that exam, I'm completely cooked.",
                        translations: [
                            "Korean": "완전 지치다, 망하다",
                            "Chinese": "精疲力尽, 筋疲力尽",
                            "Spanish": "Agotado, acabado, en mala situación"
                        ]
                    ),
                    SlangCard(
                        term: "It's over for me",
                        pronunciation: "its oh-ver for me",
                        meaning: "being in a troubled or challenging situation",
                        example: "I forgot to submit my assignment. It's over for me!",
                        translations: [
                            "Korean": "난 끝났어, 이제 망했어",
                            "Chinese": "你情况太糟了",
                            "Spanish": "Estoy acabado, no tengo salvación"
                        ]
                    ),
                    SlangCard(
                        term: "Let him cook",
                        pronunciation: "let him cook",
                        meaning: "Allow someone to perform without interruption they're about to do a good job",
                        example: "Don't rush him, let him cook and you'll see amazing results.",
                        translations: [
                            "Korean": "방해하지 말고 지켜봐, 곧 멋진 결과를 보여줄 거야",
                            "Chinese": "要有耐心，他会变得很棒",
                            "Spanish": "Déjalo trabajar, está a punto de hacer algo increíble"
                        ]
                    ),
                    SlangCard(
                        term: "Rizz",
                        pronunciation: "rizz",
                        meaning: "Charisma or charm, in the context of attracting a romantic partner",
                        example: "That guy has serious rizz, he gets all the dates.",
                        translations: [
                            "Korean": "매력, 끌어당기는 힘",
                            "Chinese": "性张力, 有魅力的",
                            "Spanish": "Carisma, encanto para atraer parejas"
                        ]
                    ),
                    SlangCard(
                        term: "I Can't Lie",
                        pronunciation: "i cant lie",
                        meaning: "emphasize honesty or truthfulness",
                        example: "ICL, that movie was actually really good.",
                        translations: [
                            "Korean": "솔직히 말해서",
                            "Chinese": "说实话",
                            "Spanish": "No voy a mentir"
                        ]
                    ),

                    SlangCard(
                        term: "Piss Me Off",
                        pronunciation: "piss me off",
                        meaning: "express annoyance or frustration",
                        example: "That slow internet really PMO.",
                        translations: [
                            "Korean": "짜증나게 하다",
                            "Chinese": "让我生气",
                            "Spanish": "Me molesta mucho"
                        ]
                    ),

                    SlangCard(
                        term: "Locked in",
                        pronunciation: "locked in",
                        meaning: "Completely focused on a task, highly concentrated",
                        example: "Don't disturb her, she's locked in on finishing this project.",
                        translations: [
                            "Korean": "완전히 집중하다, 몰입하다",
                            "Chinese": "全神贯注, 专心致志",
                            "Spanish": "Completamente concentrado, enfocado"
                        ]
                    ),
                    SlangCard(
                        term: "Crashing out",
                        pronunciation: "crash-ing out",
                        meaning: "Having a breakdown, worrying excessively",
                        example: "She's crashing out over her final exams.",
                        translations: [
                            "Korean": "무너지다, 심하게 걱정하다",
                            "Chinese": "崩溃, 过度担忧",
                            "Spanish": "Tener una crisis, preocuparse excesivamente"
                        ]
                    ),
                    SlangCard(
                        term: "Tweaking",
                        pronunciation: "twee-king",
                        meaning: "Acting slightly strange, confused, or worried; being on edge",
                        example: "Why are you tweaking? It's just a small test.",
                        translations: [
                            "Korean": "약간 불안해하다, 초조해하다",
                            "Chinese": "神经紧张, 焦虑不安",
                            "Spanish": "Actuar de forma extraña, estar nervioso"
                        ]
                    ),
                    SlangCard(
                        term: "Don't cry over spilled milk",
                        pronunciation: "dont cry oh-ver spilled milk",
                        meaning: "Don't worry about things that have already happened",
                        example: "You lost the game, but don't cry over spilled milk. Focus on the next one.",
                        translations: [
                            "Korean": "이미 지난 일에 연연하지 마라",
                            "Chinese": "不要为已经发生的事而懊恼",
                            "Spanish": "No llores por la leche derramada (no te lamentes por lo que ya pasó)"
                        ]
                    ),
                
                    SlangCard(
                        term: "Spill the tea",
                        pronunciation: "spill the tee",
                        meaning: "To share gossip or reveal secrets",
                        example: "Come on, spill the tea about your date last night!",
                        translations: [
                            "Korean": "가십이나 비밀을 폭로하다",
                            "Chinese": "爆料, 分享八卦",
                            "Spanish": "Contar el chisme, revelar secretos"
                        ]
                    ),
                    SlangCard(
                        term: "Cat's out of the bag",
                        pronunciation: "cats out of the bag",
                        meaning: "A secret has been revealed or exposed",
                        example: "Well, the cat's out of the bag now that everyone knows about the surprise party.",
                        translations: [
                            "Korean": "비밀이 드러나다",
                            "Chinese": "秘密已经泄露",
                            "Spanish": "Se destapó el secreto, se descubrió la verdad"
                        ]
                    ),
                    
                    SlangCard(
                        term: "In the nick of time",
                        pronunciation: "in the nick of time",
                        meaning: "At the last possible moment, just in time",
                        example: "The ambulance arrived in the nick of time to save her life.",
                        translations: [
                            "Korean": "아슬아슬하게 제시간에",
                            "Chinese": "在最后一刻, 恰好及时",
                            "Spanish": "Justo a tiempo, en el último momento"
                        ]
                    ),
                    SlangCard(
                        term: "It's not rocket science",
                        pronunciation: "its not rock-et sy-ence",
                        meaning: "Something is not complicated",
                        example: "Setting up this app is not rocket science, just follow the instructions.",
                        translations: [
                            "Korean": "그렇게 어려운 일이 아니다",
                            "Chinese": "这又不是什么难事",
                            "Spanish": "No es nada del otro mundo, no es tan difícil"
                        ]
                    ),
                    SlangCard(
                        term: "Cut to the chase",
                        pronunciation: "cut to the chase",
                        meaning: "Get to the point without wasting time on unnecessary details",
                        example: "Let's cut to the chase: are you interested in the job or not?",
                        translations: [
                            "Korean": "핵심으로 바로 들어가다",
                            "Chinese": "开门见山, 直奔主题",
                            "Spanish": "Ir al grano, no andarse con rodeos"
                        ]
                    )
                ]),
        ]
        
        setupSpeechRecognition()
        setupAudioSession()
        // Add observer for deck changes
                self.$selectedDeckIndex.sink { [weak self] _ in
                    self?.updateSpeechRecognizerForCurrentLanguage()
                    self?.showPronunciationFeedback = false
                    self?.currentCardIndex = 0
                }.store(in: &cancellables)
                
                // Check if user is already logged in
                checkLoginStatus()
    }
    
    
    var currentDeck: LanguageDeck {
        decks[selectedDeckIndex]
    }
    
    var currentCard: SlangCard {
        currentDeck.cards[currentCardIndex]
    }
    func masteredCardsCount(for deckIndex: Int) -> Int {
        return decks[deckIndex].cards.filter { $0.mastered }.count
    }
    func nextCard() {
        isShowingAnswer = false
        if currentCardIndex < currentDeck.cards.count - 1 {
            currentCardIndex += 1
        } else {
            // Restart from the beginning
            currentCardIndex = 0
        }
        
        setupAudioSession()  // Reset audio session back to playback mode
    }
    
    func previousCard() {
        isShowingAnswer = false
        showPronunciationFeedback = false
        if currentCardIndex > 0 {
            currentCardIndex -= 1
        } else {
            // Go to the last card
            currentCardIndex = currentDeck.cards.count - 1
        }
    }
    
    func toggleAnswer() {
        isShowingAnswer.toggle()
    }
    
    func markAsMastered() {
        var updatedDecks = decks
        updatedDecks[selectedDeckIndex].cards[currentCardIndex].mastered = true
        decks = updatedDecks
        score += 10
        saveUserProgress()
    }
    
    // Add this method to update the speech recognizer when language changes
    private func updateSpeechRecognizerForCurrentLanguage() {
        let language = currentDeck.language
        var localeIdentifier = "en-US"  // Default
        
        // Set the appropriate locale based on the language
        switch language {
        case "Chinese":
            localeIdentifier = "zh-CN"
        case "Korean":
            localeIdentifier = "ko-KR"
        case "Japanese":
            localeIdentifier = "ja-JP"
        case "Spanish":
            localeIdentifier = "es-ES"
        default:
            localeIdentifier = "en-US"
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
    }

    private func setupSpeechRecognition() {
        updateSpeechRecognizerForCurrentLanguage()
            
            // Request authorization
            SFSpeechRecognizer.requestAuthorization { authStatus in
                OperationQueue.main.addOperation {
                    switch authStatus {
                    case .authorized:
                        print("Speech recognition authorized")
                    case .denied:
                        print("Speech recognition denied")
                    case .restricted:
                        print("Speech recognition restricted")
                    case .notDetermined:
                        print("Speech recognition not determined")
                    @unknown default:
                        print("Unknown authorization status")
                    }
                }
            }
        }
    
    func startRecording() {
        // Cancel any existing timer
        autoAdvanceTimer?.invalidate()
        // Check if a recording is already in progress
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecording = false
            return
        }
        
        // Make sure we're using the correct language
        updateSpeechRecognizerForCurrentLanguage()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
                print("Speech recognizer is not available for the current locale")
                return
            }
        
        do {
            // Cancel the previous task if it's running
            recognitionTask?.cancel()
            recognitionTask = nil
            
            // Configure the audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            // Setup audio input
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            // Start recognition
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    self.pronunciationResult = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.isRecording = false
                    self.evaluatePronunciation()
                }
            }
            
            isRecording = true
            pronunciationResult = ""
            pronunciationFeedback = ""
            showPronunciationFeedback = false
            
        } catch {
            print("Recording failed: \(error)")
            isRecording = false
        }
    }
    
    func evaluatePronunciation() {
        let userPronunciation = pronunciationResult.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let correctPronunciation = currentCard.pronunciation.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let term = currentCard.term.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the pronunciation is empty
        if userPronunciation.isEmpty {
            pronunciationFeedback = "I couldn't hear anything. Please try again."
            showPronunciationFeedback = true
            return
        }
        
        // Split strings into words for better comparison
        let userWords = userPronunciation.components(separatedBy: .whitespaces)
        let correctWords = correctPronunciation.components(separatedBy: .whitespaces)
        let termWords = term.components(separatedBy: .whitespaces)
        
        // Check if user pronunciation contains any of the correct words
        let matchedPronunciationWords = correctWords.filter { correctWord in
            userWords.contains { $0.contains(correctWord) || correctWord.contains($0) }
        }
        
        let matchedTermWords = termWords.filter { termWord in
            userWords.contains { $0.contains(termWord) || termWord.contains($0) }
        }
        
        // Calculate match percentages
        let pronunciationMatchPercent = Double(matchedPronunciationWords.count) / Double(correctWords.count)
        let termMatchPercent = Double(matchedTermWords.count) / Double(termWords.count)
        
        print("User said: \(userPronunciation)")
        print("Correct: \(correctPronunciation)")
        print("Match percentages - Pronunciation: \(pronunciationMatchPercent), Term: \(termMatchPercent)")
        
        
        // Determine feedback based on match percentages
        if pronunciationMatchPercent > 0.5 || termMatchPercent > 0.5 {
            pronunciationFeedback = "Great job! 🎉"
            score += 5
            
            // Auto-mark as mastered
            if !currentCard.mastered {
                markAsMastered()
            }
            
            // Set timer to auto-advance to next card
            autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.nextCard()
            }
        } else if pronunciationMatchPercent > 0.2 || termMatchPercent > 0.2 {
            pronunciationFeedback = "Getting closer! Try again."
        } else {
            pronunciationFeedback = "Keep practicing! Try to say: \(correctPronunciation)"
        }
        
        showPronunciationFeedback = true
        
    // Auto-hide feedback after 3 seconds
       DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
           withAnimation {
               self.showPronunciationFeedback = false
           }
       }
        
        setupAudioSession()  // Reset audio session back to playback mode
    }
    
    private func calculateSimilarity(between string1: String, and string2: String) -> Double {
        // Very simple similarity measure
        let set1 = Set(string1)
        let set2 = Set(string2)
        
        let intersection = set1.intersection(set2).count
        let union = set1.union(set2).count
        
        return Double(intersection) / Double(union)
    }
    
    
    // MARK: - User Login and Progress Tracking
    
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // For demo, we're using a simple authentication
        // In a real app, you'd use Firebase or another auth service
        if email.contains("@") && password.count >= 6 {
            isLoggedIn = true
            username = email.components(separatedBy: "@").first ?? "User"
            loadUserProgress()
            completion(true, nil)
        } else {
            completion(false, "Invalid email or password (must be 6+ characters)")
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // For demo purposes
        if email.contains("@") && password.count >= 6 {
            isLoggedIn = true
            username = email.components(separatedBy: "@").first ?? "User"
            completion(true, nil)
        } else {
            completion(false, "Invalid email or password (must be 6+ characters)")
        }
    }
    
    func logout() {
        isLoggedIn = false
        username = ""
    }
    
    private func checkLoginStatus() {
        // In a real app, check if the user is logged in using your auth provider
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        username = UserDefaults.standard.string(forKey: "username") ?? ""
        
        if isLoggedIn {
            loadUserProgress()
        }
    }
    
    // Save and load user progress (mastered cards)
    private func saveUserProgress() {
        guard isLoggedIn else { return }
        
        // In a real app, you would save to a backend service
        // For now, we'll use UserDefaults as a simple demonstration
        
        var masteredCardIDs: [String: [String]] = [:]
        
        for (index, deck) in decks.enumerated() {
            let deckKey = "\(deck.language)_\(index)"
            let masteredIDs = deck.cards.filter { $0.mastered }.map { $0.id.uuidString }
            masteredCardIDs[deckKey] = masteredIDs
        }
        
        if let encoded = try? JSONEncoder().encode(masteredCardIDs) {
            UserDefaults.standard.set(encoded, forKey: "masteredCards_\(username)")
        }
        
        // Save score
        UserDefaults.standard.set(score, forKey: "score_\(username)")
    }
    
    private func loadUserProgress() {
        guard isLoggedIn else { return }
        
        // Load mastered cards
        if let savedData = UserDefaults.standard.data(forKey: "masteredCards_\(username)"),
           let masteredCardIDs = try? JSONDecoder().decode([String: [String]].self, from: savedData) {
            
            var updatedDecks = decks
            
            for (index, deck) in updatedDecks.enumerated() {
                let deckKey = "\(deck.language)_\(index)"
                
                if let masteredIDs = masteredCardIDs[deckKey] {
                    for i in 0..<deck.cards.count {
                        let cardID = deck.cards[i].id.uuidString
                        if masteredIDs.contains(cardID) {
                            updatedDecks[index].cards[i].mastered = true
                        }
                    }
                }
            }
            
            decks = updatedDecks
        }
        
        // Load score
        score = UserDefaults.standard.integer(forKey: "score_\(username)")
    }
    

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session successfully set up for playback")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    func speakPronunciation() {
        let language = currentDeck.language
        let textToSpeak = currentCard.term
        let utterance = AVSpeechUtterance(string: textToSpeak)
        
        switch language {
        case "Chinese":
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        case "Korean":
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        case "Japanese":
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        case "Spanish":
            utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        default:
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // Add these lines for debugging
        print("Voice: \(utterance.voice?.language ?? "No voice")")
        print("Speaking text: \(utterance.speechString)")
        
        speechSynthesizer.speak(utterance)
    }
}
