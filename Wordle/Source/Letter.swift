//
//  Letter.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-25.
//

import Foundation

struct Letter {
  enum Position {
    case NotFound
    case Wrong
    case Correct

    init(_ correct: Bool, _ contained: Bool) {
      switch (correct, contained) {
      case (true, _):
        self = .Correct
      case (false, true):
        self = .Wrong
      default:
        self = .NotFound
      }
    }
  }

  let value: String
  let position: Position
  let inCurrentAttempt: Bool
}
