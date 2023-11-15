import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:terrapoint/src/game_internals/board_tile_model.dart';

import '../game_internals/board_state.dart';
import '../game_internals/board_setting.dart';
import '../game_internals/tile.dart';
import 'board_tile.dart';
import 'terra_grid.dart';

class Board extends StatefulWidget {
  final VoidCallback? onPlayerWon;

  static final Logger _log = Logger('_Board');
  const Board({super.key, required this.setting, this.onPlayerWon});

  final BoardSetting setting;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final boardState = Provider.of<BoardState>(context, listen: false);
    for (var y = 0; y < widget.setting.n; y++) {
      for (var x = 0; x < widget.setting.m; x++) {
        BoardTile tile = BoardTile(
            boardTileModel: BoardTileModel(),
            tile: Tile(x, y),
            coordinates: [x, y]);
        boardState.tiles[tile.id] = tile;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardState>(builder: (context, boardState, child) {
      return AspectRatio(
          aspectRatio: widget.setting.m / widget.setting.n,
          child: Listener(
            onPointerDown: (details) {},
            child: Stack(
              fit: StackFit.expand,
              children: [
                TerraGrid(widget.setting.m, widget.setting.n),
                Column(
                  children: [
                    for (var y = 0; y < widget.setting.n; y++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var x = 0; x < widget.setting.m; x++)
                              Expanded(
                                child:
                                    boardState.findTileByCoordinates([x, y])!,
                              ),
                          ],
                        ),
                      )
                  ],
                )
              ],
            ),
          ));
    });
  }
}
