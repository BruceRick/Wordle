//
//  Game.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-25.
//

import Foundation
import SwiftUI

struct Game {
  var words = Words(length: 5)
  var totalAttempts = 6
  var attempts: [Attempt] = []
  var currentAttempt = Attempt()
  var selectedWord: String
  var error: WordError?

  var score = 0
  var streak = 0

  var wordLength: Int {
    selectedWord.count
  }

  var state: State {
    let attemptCorrect = attempts.last?.word == selectedWord
    let noAttemptsLeft = attempts.count == totalAttempts

    switch (attemptCorrect, noAttemptsLeft) {
    case (true, _):
      return .Won
    case (false, true):
      return .Lost
    default:
      return .InProgress
    }
  }

  init() {
    selectedWord = words.randomWord()
  }
}

extension Game {
  enum State {
    case InProgress
    case Won
    case Lost
  }

  enum WordError {
    case InvalidWord
    case MissingCharacters

    var text: String {
      switch self {
      case .InvalidWord:
        return "Invalid Word"
      case .MissingCharacters:
        return "Missing Letters"
      }
    }
  }
}

extension Game {
  mutating func enterAttempt() {
    guard state == .InProgress else {
      return
    }
    validateCurrentAttempt()
    guard error == nil else {
      return
    }
    completeAttempt()
  }

  mutating func enterLetter(_ letter: String) {
    error = nil
    if currentAttempt.letters.count < wordLength {
      currentAttempt.letters.append(letter)
    }
  }

  mutating func removeLetter() {
    error = nil
    if !currentAttempt.letters.isEmpty {
      currentAttempt.letters.removeLast()
    }
  }

  mutating func increaseScore() {
    let multipler = 100
    let baseScore = multipler * (totalAttempts + 1)
    score += baseScore - (attempts.count * multipler)
  }

  mutating func next() {
    if state == .Lost {
      score = 0
      streak = 0
    }
    
    attempts = []
    currentAttempt = Attempt()
    selectedWord = words.randomWord()
  }

  func letter(indexes: (attempt: Int, letter: Int)) -> Letter? {
    let previousAttempts = attempts
    var allAttempts = previousAttempts
    allAttempts.append(currentAttempt)
    if allAttempts.indices.contains(indexes.attempt),
       allAttempts[indexes.attempt].letters.indices.contains(indexes.letter) {
      let letterValue = allAttempts[indexes.attempt].letters[indexes.letter]
      let position = currentPosition(letter: letterValue, indexes: indexes)
      let inCurrentAttempt = !previousAttempts.indices.contains(indexes.attempt)
      return Letter(value: letterValue,
                    position: position,
                    inCurrentAttempt: inCurrentAttempt)
    }

    return nil
  }

  func currentPosition(letter: String, indexes: (attempt: Int, letter: Int)) -> Letter.Position {
    let correct = correct(letter: letter, index: indexes.letter)
    let contains = selectedWord.contains(letter)

    return Letter.Position(correct, contains)
  }

  func previousPosition(letter: String) -> Letter.Position? {
    guard previouslyAttempted(letter: letter) else {
      return nil
    }

    let correct = previouslyCorrect(letter: letter)
    let contains = selectedWord.contains(letter)

    return Letter.Position(correct, contains)
  }
}


private extension Game {
  mutating func validateCurrentAttempt() {
    let missingCharacters = currentAttempt.letters.count != wordLength
    if missingCharacters {
      error = .MissingCharacters
    } else if !words.isValid(currentAttempt.word) {
      error = .InvalidWord
    } else {
      error = nil
    }
  }

  mutating func completeAttempt() {
    let currentAttemptCopy = currentAttempt
    attempts.append(currentAttemptCopy)
    currentAttempt = Attempt()
    if state == .Won {
      increaseScore()
      streak += 1
    }
  }

  func correct(letter: String, index letterIndex: Int) -> Bool {
    let start = selectedWord.index(selectedWord.startIndex, offsetBy: letterIndex)
    let end = selectedWord.index(after: start)
    let correctChar = selectedWord[start ..< end]
    return correctChar == letter
  }

  func previouslyAttempted(letter: String) -> Bool {
    attempts.filter { $0.letters.contains(letter) }.count > 0
  }

  func previouslyCorrect(letter: String) -> Bool {
    for attempt in attempts {
      for (index, attemptLetter) in attempt.letters.enumerated() {
        if letter == attemptLetter && correct(letter: attemptLetter, index: index) {
          return true
        }
      }
    }

    return false
  }
}
