//
//  Models.swift
//  yapper
//
//  Created by Selina Song on 3/3/25.
//

// MARK: - Models.swift
import Foundation
import SwiftUI

struct SlangCard: Identifiable, Equatable {
    let id = UUID()
    let term: String
    let pronunciation: String
    let meaning: String
    let example: String
    var mastered: Bool = false
    // Option 1: Single optional translation
    let translation: String?
    // Option 2: Dictionary of translations keyed by language
    let translations: [String: String]?
    
    // Initialize with both translation options as nil by default
    init(term: String, pronunciation: String, meaning: String, example: String,
         translation: String? = nil, translations: [String: String]? = nil, mastered: Bool = false) {
        self.term = term
        self.pronunciation = pronunciation
        self.meaning = meaning
        self.example = example
        self.mastered = mastered
        self.translation = translation
        self.translations = translations
    }
}

struct LanguageDeck: Identifiable {
    let id = UUID()
    let language: String
    let flagEmoji: String
    var cards: [SlangCard]
}
