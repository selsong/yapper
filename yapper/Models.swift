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
}

struct LanguageDeck: Identifiable {
    let id = UUID()
    let language: String
    let flagEmoji: String
    var cards: [SlangCard]
}
