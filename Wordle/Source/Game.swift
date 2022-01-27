//
//  Game.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-25.
//

import Foundation
import SwiftUI

struct Game {
  var selectedWord = newWord
  var totalAttempts = 6
  var attempts: [Attempt] = []
  var currentAttempt = Attempt()

  var score = 0
  var streak = 0

  var wordLength: Int {
    selectedWord.count
  }

  var state: State {
    let attemptCorrect = attempts.last?.word == selectedWord
    let noAttemptsLeft = totalAttempts - attempts.count == 0

    switch (attemptCorrect, noAttemptsLeft) {
    case (true, _):
      return .Won
    case (false, true):
      return .Lost
    default:
      return .InProgress
    }
  }
}

extension Game {
  enum State {
    case InProgress
    case Won
    case Lost
  }
}

extension Game {
  mutating func completeAttempt() {
    guard attempts.count < totalAttempts &&
            currentAttempt.letters.count == wordLength
    else {
      return
    }

    let currentAttemptCopy = currentAttempt
    attempts.append(currentAttemptCopy)
    currentAttempt = Attempt()
    if state == .Won {
      increaseScore()
      streak += 1
    }
  }

  mutating func enterLetter(_ letter: String) {
    if currentAttempt.letters.count < wordLength {
      currentAttempt.letters.append(letter)
    }
  }

  mutating func removeLetter() {
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
    attempts = []
    currentAttempt = Attempt()
    selectedWord = Self.newWord

    if state == .Lost {
      score = 0
      streak = 0
    }
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
  static var newWord: String {
    // TODO: build actual DB.
    ["apple", "exile", "pizza", "bunks", "skunk", "whack", "munch", "first"].randomElement() ?? ""
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
