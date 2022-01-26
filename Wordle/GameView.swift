//
//  GameView.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-25.
//

import SwiftUI

struct GameView: View {
  @State var game = newGame

  //TODO: Randomize game state
  private static let selectedWord = "apple"
  private static let totalAttempts = 5
  private static var newGame: Game = { Game(selectedWord: selectedWord, totalAttempts: totalAttempts) }()

  var body: some View {
    VStack(spacing: 5) {
      header
      Spacer()
      game.state.endGameText
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(game.state.endGameTextColor)
      Spacer()
      ForEach(0 ..< game.totalAttempts, id: \.self) { attempt in
        HStack(spacing: 5) {
          ForEach(0 ..< game.wordLength, id: \.self) { letter in
            tile(game.letter(indexes: (attempt, letter)))
          }
        }
      }
      Spacer()
      Text(game.selectedWord.uppercased())
        .font(.title)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .opacity(game.state.selectedWordOpacity)
      Spacer()
      Rectangle()
        .foregroundColor(Color(.darkGray))
        .frame(height: 1)
      keyboard
        .padding(.bottom, 10)
    }
    .padding(.horizontal)
    .background(Color.black.edgesIgnoringSafeArea(.all))
  }

  @ViewBuilder
  var header: some View {
    Text("Wordle")
      .font(.title)
      .fontWeight(.bold)
      .foregroundColor(.white)
    Rectangle()
      .foregroundColor(Color(.darkGray))
      .frame(height: 1)
  }

  func tile(_ letter: Letter?) -> some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text(letter?.value.uppercased() ?? "")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.white)
        Spacer()
      }
      Spacer()
    }
    .border(letter.tileborderColor, width: 2)
    .background(letter.tileColor)
    .cornerRadius(1)
    .aspectRatio(1, contentMode: .fit)
  }

  @ViewBuilder
  var keyboardButtons: some View {
    if game.state != .InProgress {
      nextGameButton
    } else {
      wordButtons
    }
  }

  var nextGameButton: some View {
    HStack {
      Button {
        nextGame()
      } label: {
        HStack {
          Spacer()
          game.state.nextGameText
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 50)
      }
      .background(game.state.endGameTextColor)
      .cornerRadius(10)
    }.padding(.vertical, 8)
  }

  var wordButtons: some View {
    HStack(spacing: 15) {
      Button {
        enter()
      } label: {
        HStack {
          Spacer()
          Image(systemName: "checkmark.circle.fill")
            .font(.title)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 50)
      }
      .background(Color.green)
      .cornerRadius(10)
      Button {
        backspace()
      } label: {
        HStack {
          Spacer()
          Image(systemName: "delete.left.fill")
            .font(.title)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 50)
      }
      .background(Color.red)
      .cornerRadius(10)
    }.padding(.vertical, 8)
  }

  var keyRows = [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
    ["z", "x", "c", "v", "b", "n", "m"]
  ]

  var keyboard: some View {
    VStack(alignment: .center, spacing: 5) {
      keyboardButtons
      ForEach(keyRows, id: \.self) { row in
        HStack(spacing: 5) {
          ForEach(row, id: \.self) { letter in
            key(letter)
          }
        }
      }
    }
  }

  func key(_ letter: String) -> some View {
    Button {
      letterTapped(letter)
    } label: {
      HStack {
        VStack {
          Spacer()
          Text(letter.uppercased())
            .foregroundColor(.white)
            .font(.title2)
            .fontWeight(.bold)
          Spacer()
        }
      }
    }
    .frame(width: 30, height: 45)
    .background(game.previousPosition(letter: letter).keyColor)
    .cornerRadius(5)
    .disabled(game.state.inputDisabled)
  }

  func letterTapped(_ letter: String) {
    if game.currentAttempt.letters.count < game.wordLength {
      game.currentAttempt.letters.append(letter)
    }
  }

  func enter() {
    if game.attempts.count < game.totalAttempts &&
        game.currentAttempt.letters.count == game.totalAttempts {
      game.attempts.append(game.currentAttempt)
      game.currentAttempt = Attempt()
    }
  }

  func backspace() {
    if !game.currentAttempt.letters.isEmpty {
      game.currentAttempt.letters.removeLast()
    }
  }

  func nextGame() {
    game = Self.newGame
  }
}

private extension Game.State {
  var endGameText: Text {
    switch self {
    case .Won:
      return Text("You Won")
    case .Lost:
      return Text("You Lost")
    default:
      return Text(" ")
    }
  }

  var endGameTextColor: Color {
    self == .Won ? .green : .red
  }

  var selectedWordOpacity: CGFloat {
    self == .Lost ? 1 : 0
  }

  var nextGameText: Text {
    self == .Won ? Text("Next Game") : Text("New Game")
  }

  var inputDisabled: Bool {
    self != .InProgress
  }
}

private extension Letter.Position {
  var color: Color {
    switch self {
    case .Correct: return .green
    case .Wrong: return .orange
    case .NotFound: return .init(.darkGray)
    }
  }
}

private extension Optional where Wrapped == Letter {
  var tileborderColor: Color {
    guard self != nil else {
      return Letter.Position.NotFound.color
    }

    return tileColor
  }

  var tileColor: Color {
    guard let letter = self else {
      return .clear
    }

    if letter.inCurrentAttempt {
      return Letter.Position.NotFound.color
    }

    return letter.position.color
  }
}

private extension Optional where Wrapped == Letter.Position {
  var keyColor: Color {
    guard let position = self else {
      return .gray
    }

    return position.color
  }
}
