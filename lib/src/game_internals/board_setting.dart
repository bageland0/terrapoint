import 'package:flutter/foundation.dart';
import 'package:terrapoint/src/game_internals/board_state.dart';

/// The setting of an m,n,k-game.
///
/// For example, the Japanese game gomoku is a 15,15,5-game.
/// Tic Tac Toe is a 3,3,3-game.
@immutable
class BoardSetting {
  /// The number of columns. The "width" of the game board.
  final int m;

  /// The number of rows. The "height" of the game board.
  final int n;

  /// If `true`, the board will start with an `aiOpponentSide` mark in
  /// the center.

  const BoardSetting(
    this.m,
    this.n,
  );

  @override
  int get hashCode => Object.hash(m, n);

  @override
  bool operator ==(Object other) {
    return other is BoardSetting && other.m == m && other.n == n;
  }
}
