//
//  GameView.swift
//  Wordle
//
//  Created by Bruce Rick on 2022-01-25.
//

import SwiftUI

struct GameView: View {
  @State var game = Game()

  var keys = [
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
    ["z", "x", "c", "v", "b", "n", "m"]
  ]

  var body: some View {
    VStack(spacing: 5) {
      header
      topText
      tiles
      selectedWord
      divider
      keyboard
    }
    .padding(.horizontal)
    .background(Color.black.edgesIgnoringSafeArea(.all))
  }
}

private extension GameView {
  @ViewBuilder
  var header: some View {
    Text("Wordle")
      .font(.title)
      .fontWeight(.bold)
      .foregroundColor(.white)
    divider
  }

  var divider: some View {
    Rectangle()
      .foregroundColor(Color(.darkGray))
      .frame(height: 1)
  }

  @ViewBuilder
  var topText: some View {
    Text("Streak: \(game.streak) | Score: \(game.score)")
      .font(.title2)
      .fontWeight(.bold)
      .foregroundColor(.white)
      .padding(.vertical, 5)
  }

  var tiles: some View {
    ForEach(0 ..< game.totalAttempts, id: \.self) { attempt in
      HStack(spacing: 5) {
        ForEach(0 ..< game.wordLength, id: \.self) { letter in
          tile(game.letter(indexes: (attempt, letter)))
        }
      }
    }
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

  var selectedWord: some View {
    Text(game.selectedWord.uppercased())
      .font(.title)
      .fontWeight(.bold)
      .foregroundColor(.white)
      .opacity(game.state.selectedWordOpacity)
      .padding(.vertical, 5)
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
        game.next()
      } label: {
        HStack {
          Spacer()
          game.state.nextGameText
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 40)
      }
      .background(game.state == .Won ? .green : .red)
      .cornerRadius(10)
    }.padding(.vertical, 8)
  }

  var wordButtons: some View {
    HStack(spacing: 15) {
      Button {
        game.completeAttempt()
      } label: {
        HStack {
          Spacer()
          Image(systemName: "checkmark.circle.fill")
            .font(.title)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 40)
      }
      .background(Color.green)
      .cornerRadius(10)
      Button {
        game.removeLetter()
      } label: {
        HStack {
          Spacer()
          Image(systemName: "delete.left.fill")
            .font(.title)
            .foregroundColor(.white)
          Spacer()
        }
        .frame(height: 40)
      }
      .background(Color.red)
      .cornerRadius(10)
    }.padding(.vertical, 8)
  }

  var keyboard: some View {
    VStack(alignment: .center, spacing: 5) {
      keyboardButtons
      ForEach(keys, id: \.self) { row in
        HStack(spacing: 5) {
          ForEach(row, id: \.self) { letter in
            key(letter)
          }
        }
      }
    }.padding(.bottom, 10)
  }

  func key(_ letter: String) -> some View {
    Button {
      game.enterLetter(letter)
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
}

private extension Game.State {
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
    guard let letter = self,
          !letter.inCurrentAttempt
    else {
      return Letter.Position.NotFound.color
    }

    return tileColor
  }

  var tileColor: Color {
    guard let letter = self else {
      return .clear
    }

    if letter.inCurrentAttempt {
      return .clear
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
