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
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        // Initialize with sample data
        self.decks = [
            LanguageDeck(
                language: "Chinese",
                flagEmoji: "🇨🇳",
                cards: [
                    SlangCard(term: "六 / 666", pronunciation: "liù / liù liù liù", meaning: "Awesome skills, good job", example: "Often used in gaming context"),
                    SlangCard(term: "牛", pronunciation: "niú", meaning: "Awesome, super cool", example: "你真牛! (You're so awesome!)"),
                    SlangCard(term: "哥们儿", pronunciation: "gēmenr", meaning: "Dude, Bro", example: "哥们儿，你去哪里? (Dude, where are you going?)"),
                    SlangCard(term: "啥", pronunciation: "shá", meaning: "What?", example: "Same as 什么 (shén me)"),
                    SlangCard(term: "哇塞", pronunciation: "wāsài", meaning: "Wow", example: "哇塞! 这太棒了! (Wow! This is great!)"),
                    SlangCard(term: "酷", pronunciation: "kù", meaning: "Cool", example: "这很酷! (That's cool!)"),
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
                    SlangCard(term: "绝绝子", pronunciation: "jué jué zi", meaning: "Absolutely amazing", example: "This restaurant is 绝绝子!")
                ]
            ),
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
                ]
            )
        ]
        
        setupSpeechRecognition()
    }
    
    var currentDeck: LanguageDeck {
        decks[selectedDeckIndex]
    }
    
    var currentCard: SlangCard {
        currentDeck.cards[currentCardIndex]
    }
    
    func nextCard() {
        isShowingAnswer = false
        if currentCardIndex < currentDeck.cards.count - 1 {
            currentCardIndex += 1
        } else {
            // Restart from the beginning
            currentCardIndex = 0
        }
    }
    
    func previousCard() {
        isShowingAnswer = false
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
    }
    
    private func setupSpeechRecognition() {
        // Set up speech recognition
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    func startRecording() {
        // Check if a recording is already in progress
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecording = false
            return
        }
        
        let language = currentDeck.language
        var localeIdentifier = "en-US"  // Default
        
        // Set the appropriate locale based on the language
        switch language {
        case "Chinese":
            localeIdentifier = "zh-CN"
        case "Korean":
            localeIdentifier = "ko-KR"
        // Add more languages as needed
        default:
            localeIdentifier = "en-US"
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        
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
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
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
        // Simple evaluation by checking if the recognized text contains the term or pronunciation
        let userPronunciation = pronunciationResult.lowercased()
        let correctPronunciation = currentCard.pronunciation.lowercased()
        let term = currentCard.term.lowercased()
        
        // Calculate similarity
        let similarity = calculateSimilarity(between: userPronunciation, and: correctPronunciation)
        
        if userPronunciation.contains(term) || userPronunciation.contains(correctPronunciation) || similarity > 0.6 {
            pronunciationFeedback = "Great job! 🎉"
            score += 5
        } else if similarity > 0.3 {
            pronunciationFeedback = "Getting closer! Try again."
        } else {
            pronunciationFeedback = "Keep practicing! Try to say: \(correctPronunciation)"
        }
        
        showPronunciationFeedback = true
    }
    
    private func calculateSimilarity(between string1: String, and string2: String) -> Double {
        // Very simple similarity measure
        let set1 = Set(string1)
        let set2 = Set(string2)
        
        let intersection = set1.intersection(set2).count
        let union = set1.union(set2).count
        
        return Double(intersection) / Double(union)
    }
}
