import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:terrapoint/src/game_internals/tile_moves.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/board_state.dart';
import '../game_internals/board_tile_model.dart';
import '../game_internals/tile.dart';
import '../style/palette.dart';

enum BoardTileState {
  isChecked,
  isSelected,
  isMoveIndicated,
  isBlueMove,
  isRedMove,
  isPurpleMove,
  isDefault,
}

class BoardTile extends StatefulWidget {
  /// The tile's position on the board.
  final BoardTileModel boardTileModel;
  final Tile tile;
  final List<int> coordinates;

  String get id {
    return BoardTile.idByCoordinates(coordinates);
  }

  static String idByCoordinates(List<int> coordinates) {
    return '${coordinates[0]};${coordinates[1]}';
  }

  static final Logger _log = Logger('_BoardTile');

  const BoardTile({
    super.key,
    required this.boardTileModel,
    required this.tile,
    required this.coordinates,
  });

  @override
  State<BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<BoardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late BoardTileState boardTileState;
  late BoardState boardState;

  Side? _previousOwner;

  //late bool isChecked;
  //late bool isSelected;

  //_BoardTileState() {
  //  isChecked = false;
  //  isSelected = false;
  //}

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardState>(builder: (context, boardState, child) {
      this.boardState = boardState;
      Widget representation;

      var color = Colors.amber;

      if (widget.boardTileModel.isSelected) {
        boardTileState = BoardTileState.isSelected;
      } else if (widget.boardTileModel.isChecked) {
        boardTileState = BoardTileState.isChecked;
      } else if (widget.boardTileModel.isMoveIndicated) {
        boardTileState = BoardTileState.isMoveIndicated;
      } else {
        boardTileState = BoardTileState.isDefault;
      }

      if (widget.boardTileModel.isPurpleMove) {
        boardTileState = BoardTileState.isPurpleMove;
      } else if (widget.boardTileModel.isBlueMove) {
        boardTileState = BoardTileState.isBlueMove;
      } else if (widget.boardTileModel.isRedMove) {
        boardTileState = BoardTileState.isRedMove;
      }

      switch (boardTileState) {
        case BoardTileState.isSelected:
          representation = Container(
            width: 100,
            height: 100,
            color: Colors.yellow,
            child: _PointPoint(
              color: color,
              variantSeed: widget.tile.hashCode,
            ),
          );
          break;

        case BoardTileState.isChecked:
          representation = _PointPoint(
            color: color,
            variantSeed: widget.tile.hashCode,
          );
          break;

        case BoardTileState.isPurpleMove:
          representation = Container(
            width: 100,
            height: 100,
            color: Colors.purple,
          );
          break;

        case BoardTileState.isBlueMove:
          representation = Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          );
          break;

        case BoardTileState.isRedMove:
          representation = Container(
            width: 100,
            height: 100,
            color: Colors.red,
          );
          break;

        case BoardTileState.isMoveIndicated:
          representation = Container(
            width: 100,
            height: 100,
            color: Colors.green,
          );
          break;

        case BoardTileState.isDefault:
          representation = const SizedBox.expand();
          break;
      }
      return InkResponse(
        onTap: () async {
          //BoardTile._log.info("isChecked: ${widget.boardTileModel.isChecked}");
          //BoardTile._log.info(
          //    "isMoveIndicated: ${widget.boardTileModel.isMoveIndicated}");
          if (!widget.boardTileModel.isChecked &&
              !widget.boardTileModel.isMoveIndicated) {
            boardState.take(widget.tile);
            widget.boardTileModel.setChecked(true);
          } else {
            var (isSelecting, possibleMoves) = showAvailableMoves();
            BoardTile._log.info("it in fucin else");
            BoardTile._log.info("isSelecting: ${isSelecting}");
            BoardTile._log.info("possibleMoves: ${possibleMoves}");
            isSelecting
                ? boardState.maybeSelect(widget)
                : _showContextMenu(context, possibleMoves);
          }
        },
        child: representation,
      );
    });
  }

  void _showContextMenu(BuildContext context, possibleMoves) async {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);
    Rect rect = Rect.fromPoints(
        position,
        Offset(position.dx + renderBox.size.width,
            position.dy + renderBox.size.height));

    boardState.colorPossibleMoves(possibleMoves);

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          rect, Offset.zero & MediaQuery.of(context).size),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Container(
              color: Colors.blue,
              child: ListTile(
                title: Text(possibleMoves.keys.toList().first),
                onTap: () {
                  boardState.checkMove(
                      possibleMoves, possibleMoves.keys.toList().first);
                  Navigator.pop(context);
                },
              )),
        ),
        PopupMenuItem(
            child: Container(
          color: Colors.red,
          child: ListTile(
            title: Text(possibleMoves.keys.toList().last),
            onTap: () {
              boardState.checkMove(
                  possibleMoves, possibleMoves.keys.toList().last);
              Navigator.pop(context);
            },
          ),
        )),
        // Добавьте дополнительные элементы меню, если нужно
      ],
    );
  }

  _isLastTile() {
    List possibleMoves = [];
    Map possibleMovesAssoc = {};
    for (final Set<BoardTile> tileSet
        in boardState.tileMoves!.resultAssoc.values) {
      if (tileSet.isNotEmpty && tileSet.last == widget) {
        possibleMoves.add(tileSet);

        var key = boardState.tileMoves!.resultAssoc.keys.firstWhere(
            (key) => boardState.tileMoves!.resultAssoc[key] == tileSet);

        possibleMovesAssoc[key] = boardState.tileMoves!.resultAssoc[key];
      }
    }
    if (possibleMovesAssoc.isNotEmpty) {
      return (true, possibleMovesAssoc);
    }
    return (false, null);
  }

  showAvailableMoves() {
    //BoardTile._log.info(
    //    "${boardState.tileMoves!.resultAssoc} ${boardState.tileMoves!.resultAssoc.isEmpty}");

    BoardTile._log.info("in da moves");
    BoardTile._log.info("tileMoves: ${boardState.tileMoves!.resultAssoc}");
    if (boardState.tileMoves!.resultAssoc.isEmpty) {
      boardState.tileMoves =
          TileMoves(coordinates: widget.coordinates, boardState: boardState);
      boardState.tileMoves!.obtainDirections();

      BoardTile._log.info(
          "resultAssocIsEmpty: ${boardState.tileMoves!.resultAssoc.isEmpty}");
      boardState.tileMoves!.drawDirections();

      return (true, null);
    }

    var (isLastTile, possibleMoves) = _isLastTile();

    if (boardState.tileMoves!.resultAssoc.isNotEmpty &&
        widget.boardTileModel.isMoveIndicated &&
        isLastTile) {
      //BoardTile._log.info("yeah");
      return (false, possibleMoves);
    }
    return (true, null);
  }
}

class _PointPoint extends StatelessWidget {
  final Color color;

  /// An integer that will be used to select a variant of the mark.
  /// Can be any integer.
  final int variantSeed;

  const _PointPoint({
    super.key,
    required this.color,
    required this.variantSeed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width =
          constraints.maxWidth * MediaQuery.of(context).devicePixelRatio;
      return Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            size: Size(200.0, 200.0), // Размер круга
            painter: PointPointPainter(),
          ),
        ],
      );
    });
  }
}

class PointPointPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black // Цвет круга
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * .3;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
