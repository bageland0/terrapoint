import 'package:logging/logging.dart';
import 'package:terrapoint/src/game_internals/board_state.dart';
import 'package:terrapoint/src/play_session/board_tile.dart';

enum Direction {
  up,
  right,
  down,
  left,
}

class TileMoves {
  static final Logger _log = Logger('BoardState');
  final List<int> coordinates;
  final BoardState boardState;

  TileMoves({required this.coordinates, required this.boardState});

  List<int> currentCoordinates = [0, 0];
  Set<BoardTile> _tiles = {};
  Map<String, Set<BoardTile>> _assocTiles = {};

  Set<BoardTile>? get result => _tiles;
  Map<String, Set<BoardTile>> get resultAssoc => _assocTiles;

  _longFirst(Direction direction, bool isByRightSide) {
    int firstSteps = 2;
    int secondSteps = 1;
    //TileMoves._log.info(currentCoordinates);
    //TileMoves._log.info(coordinates);

    /// ID мува это короче вот:
    ///  направление-поправойстороне?-сначаладлинный?
    switch (direction) {
      case Direction.up:
        if (isByRightSide) {
          _up(firstSteps, 'up-true-true');
          _right(secondSteps, 'up-true-true');
        } else {
          _up(firstSteps, 'up-false-true');
          _left(secondSteps, 'up-false-true');
        }
        break;
      case Direction.right:
        if (isByRightSide) {
          _right(firstSteps, 'right-true-true');
          _down(secondSteps, 'right-true-true');
        } else {
          _right(firstSteps, 'right-false-true');
          _up(secondSteps, 'right-false-true');
        }
        break;
      case Direction.down:
        if (isByRightSide) {
          _down(firstSteps, 'down-true-true');
          _left(secondSteps, 'down-true-true');
        } else {
          _down(firstSteps, 'down-false-true');
          _right(secondSteps, 'down-false-true');
        }
        break;
      case Direction.left:
        if (isByRightSide) {
          _left(firstSteps, 'left-true-true');
          _up(secondSteps, 'left-true-true');
        } else {
          _left(firstSteps, 'left-false-true');
          _down(secondSteps, 'left-false-true');
        }
        break;
    }
  }

  _shortFirst(Direction direction, bool isByRightSide) {
    int firstSteps = 1;
    int secondSteps = 2;

    switch (direction) {
      case Direction.up:
        if (isByRightSide) {
          _right(firstSteps, 'up-true-false');
          _up(secondSteps, 'up-true-false');
        } else {
          _left(firstSteps, 'up-false-false');
          _up(secondSteps, 'up-false-false');
        }
        break;
      case Direction.right:
        if (isByRightSide) {
          _down(firstSteps, 'right-true-false');
          _right(secondSteps, 'right-true-false');
        } else {
          _up(firstSteps, 'right-false-false');
          _right(secondSteps, 'right-false-false');
        }
        break;
      case Direction.down:
        if (isByRightSide) {
          _left(firstSteps, 'down-true-false');
          _down(secondSteps, 'down-true-false');
        } else {
          _right(firstSteps, 'down-false-false');
          _down(secondSteps, 'down-false-false');
        }
        break;
      case Direction.left:
        if (isByRightSide) {
          _up(firstSteps, 'left-true-false');
          _left(secondSteps, 'left-true-false');
        } else {
          _down(firstSteps, 'left-false-false');
          _left(secondSteps, 'left-false-false');
        }
        break;
    }
  }

  _addTiles(String moveId) {
    var tile = boardState
        .findTileByCoordinates([currentCoordinates[0], currentCoordinates[1]]);
    _tiles.add(tile!);
    if (_assocTiles[moveId] == null) {
      _assocTiles[moveId] = {};
    }
    _assocTiles[moveId]!.add(tile);
  }

  _up(steps, String moveId) {
    while (currentCoordinates[1] >= coordinates[1] - steps) {
      currentCoordinates[1]--;
      steps--;

      _addTiles(moveId);
    }
  }

  _down(steps, String moveId) {
    while (currentCoordinates[1] <= coordinates[1] + steps) {
      currentCoordinates[1]++;
      steps--;

      _addTiles(moveId);
    }
  }

  _left(steps, String moveId) {
    while (currentCoordinates[0] >= coordinates[0] - steps) {
      currentCoordinates[0]--;
      steps--;

      _addTiles(moveId);
    }
  }

  _right(steps, String moveId) {
    while (currentCoordinates[0] <= coordinates[0] + steps) {
      currentCoordinates[0]++;
      steps--;

      _addTiles(moveId);
    }
  }

  drawDirections() {
    _tiles.forEach((tile) {
      tile.boardTileModel.setMoveIndicated(true);
    });
  }

  obtainDirections() {
    _obtainDirection(
        direction: Direction.down, isLongFirst: true, isByRightSide: true);
    _obtainDirection(
        direction: Direction.right, isLongFirst: true, isByRightSide: true);
    _obtainDirection(
        direction: Direction.up, isLongFirst: true, isByRightSide: true);
    _obtainDirection(
        direction: Direction.left, isLongFirst: true, isByRightSide: true);

    _obtainDirection(
        direction: Direction.down, isLongFirst: true, isByRightSide: false);
    _obtainDirection(
        direction: Direction.right, isLongFirst: true, isByRightSide: false);
    _obtainDirection(
        direction: Direction.up, isLongFirst: true, isByRightSide: false);
    _obtainDirection(
        direction: Direction.left, isLongFirst: true, isByRightSide: false);

    _obtainDirection(
        direction: Direction.down, isLongFirst: false, isByRightSide: true);
    _obtainDirection(
        direction: Direction.right, isLongFirst: false, isByRightSide: true);
    _obtainDirection(
        direction: Direction.up, isLongFirst: false, isByRightSide: true);
    _obtainDirection(
        direction: Direction.left, isLongFirst: false, isByRightSide: true);

    _obtainDirection(
        direction: Direction.down, isLongFirst: false, isByRightSide: false);
    _obtainDirection(
        direction: Direction.right, isLongFirst: false, isByRightSide: false);
    _obtainDirection(
        direction: Direction.up, isLongFirst: false, isByRightSide: false);
    _obtainDirection(
        direction: Direction.left, isLongFirst: false, isByRightSide: false);
  }

  _obtainDirection(
      {required Direction direction,
      required bool isLongFirst,
      required bool isByRightSide}) {
    currentCoordinates = List.from(coordinates);

    if (isLongFirst) {
      _longFirst(direction, isByRightSide);
    } else {
      _shortFirst(direction, isByRightSide);
    }
  }

  Map<String, Set<BoardTile>> findAssocWithCoordinates(
      List<int> targetCoordinates) {
    Map<String, Set<BoardTile>> result = {};

    _assocTiles.forEach((key, value) {
      if (value.isNotEmpty) {
        BoardTile lastTile = value.last;
        if (lastTile.coordinates[0] == targetCoordinates[0] &&
            lastTile.coordinates[1] == targetCoordinates[1]) {
          result[key] = value;
        }
      }
    });

    return result;
  }
}
