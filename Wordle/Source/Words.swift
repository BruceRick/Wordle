//
//  Words.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-27.
//

import Foundation

struct Words {
  var length: Int

  lazy var words: [String] = {
    if let wordsFilePath = Bundle.main.path(forResource: "wordDatabase", ofType: nil) {
      do {
        let wordsString = try String(contentsOfFile: wordsFilePath)
        let wordLines = wordsString.components(separatedBy: .newlines)
        return wordLines.filter { $0.count == length }
      } catch {
        fatalError("Dictonary file is unreadable")
      }
    } else {
      fatalError("Dictionary file not found")
    }
  }()

  mutating func randomWord() -> String {
    words.randomElement()!
  }

  mutating func isValid(_ word: String) -> Bool {
    words.contains(word)
  }
}
