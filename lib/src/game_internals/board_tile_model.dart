import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
//import 'package:terrapoint/src/game_internals/board_setting.dart';
//import 'package:terrapoint/src/game_internals/tile.dart';
//import 'package:terrapoint/src/play_session/board_tile.dart';

class BoardTileModel extends ChangeNotifier {
  static final Logger _log = Logger('BoardTileModel');

  bool isChecked = false;
  bool isSelected = false;
  bool isMoveIndicated = false;
  bool isPurpleMove = false;
  bool isBlueMove = false;
  bool isRedMove = false;

  //set checked(bool isChecked) {
  //  isChecked = isChecked;
  //  notifyListeners();
  //}

  //set selected(bool isSelected) {
  //  isSelected = isSelected;
  //  notifyListeners();
  //}

  void setChecked(bool isChecked) {
    this.isChecked = isChecked;
    notifyListeners();
  }

  void setSelected(bool isSelected) {
    this.isSelected = isSelected;
    notifyListeners();
  }

  void setMoveIndicated(bool isMoveIndicated) {
    this.isMoveIndicated = isMoveIndicated;
    notifyListeners();
  }

  void setBlue(bool isBlueMove) {
    this.isBlueMove = isBlueMove;
    notifyListeners();
  }

  void setRed(bool isRedMove) {
    this.isRedMove = isRedMove;
    notifyListeners();
  }

  void setPurple(bool isPurpleMove) {
    this.isPurpleMove = isPurpleMove;
    notifyListeners();
  }

  void unsetIndication() {
    isRedMove = false;
    isPurpleMove = false;
    isBlueMove = false;
    isMoveIndicated = false;
    notifyListeners();
  }
}
