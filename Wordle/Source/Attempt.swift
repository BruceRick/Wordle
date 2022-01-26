//
//  Attempt.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-25.
//

import Foundation

struct Attempt {
  var letters: [String] = []

  var word: String {
    letters.joined(separator: "")
  }
}
