import 'package:flutter/material.dart';

int rowLength = 10;
int colLength = 15;

enum TetrisShapes {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

enum Direction {
  right,
  left,
  down,
}

const Map<TetrisShapes, Color> tetrisColors = {
  TetrisShapes.L: Colors.amber,
  TetrisShapes.J: Colors.teal,
  TetrisShapes.I: Colors.red,
  TetrisShapes.O: Colors.green,
  TetrisShapes.S: Colors.orange,
  TetrisShapes.Z: Colors.blue,
  TetrisShapes.T: Colors.purple,
};
