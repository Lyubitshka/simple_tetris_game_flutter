import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tetris_game/pice.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';

/*

GAME BOARD

A 2x2 grid with null representing an empty spce

A non empty space will have the color to represent the landed pieces

*/

//create game board
List<List<TetrisShapes?>> gameBoard = List.generate(
    colLength, (index) => List.generate(rowLength, (index) => null));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currPiece = Piece(type: TetrisShapes.L);

  int currentScore = 0;

  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    startGame();
  }

  void startGame() {
    currPiece.initializePiece();

    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        clearLines();
        checkLanding();

        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }

        currPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Game Over'),
              content: Text('Your score is $currentScore'),
              actions: [
                TextButton(
                    onPressed: () {
                      resetGame();

                      Navigator.pop(context);
                    },
                    child: Text('Play again!'))
              ],
            ));
  }

  void resetGame() {
    gameBoard = List.generate(
      colLength,
      (index) => List.generate(
        rowLength,
        (index) => null,
      ),
    );
    gameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  bool checkCollision(Direction direction) {
    for (int i = 0; i < currPiece.position.length; i++) {
      int row = (currPiece.position[i] / rowLength).floor();
      int col = currPiece.position[i] % rowLength;
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }
      if (row >= 0 && col >= 0) {
        if (gameBoard[row][col] != null) {
          return true;
        }
      }
    }
    return false;
  }

  void checkLanding() {
    //if going down is occupied
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currPiece.position.length; i++) {
        int row = (currPiece.position[i] / rowLength).floor();
        int col = currPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currPiece.type;
        }
      }
      //once land create new piece
      createNewPiece();
    }
  }

  void createNewPiece() {
    Random rand = Random();
    TetrisShapes randomShape =
        TetrisShapes.values[rand.nextInt(TetrisShapes.values.length)];
    currPiece = Piece(type: randomShape);
    currPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    //make sure the move id valid
    if (!checkCollision(Direction.left)) {
      setState(() {
        currPiece.movePiece(Direction.left);
      });
    }
  }

  void rotate() {
    setState(() {
      currPiece.rotatePiece();
    });
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currPiece.movePiece(Direction.right);
      });
    }
  }

  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;

      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(row, (index) => null);

        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
                itemCount: rowLength * colLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength,
                ),
                itemBuilder: (context, index) {
                  //get row and col for each index:
                  int row = (index / rowLength).floor();
                  int col = index % rowLength;

                  //current piece:
                  if (currPiece.position.contains(index)) {
                    return Pixel(
                      color: currPiece.color,
                    );
                  }
                  //landed piece:
                  else if (gameBoard[row][col] != null) {
                    final TetrisShapes? tetrisShapeType = gameBoard[row][col];
                    return Pixel(
                      color: tetrisColors[tetrisShapeType],
                    );
                  }
                  // blank pixel:
                  else {
                    return Pixel(
                      color: Colors.grey.shade900,
                    );
                  }
                }),
          ),
          Text(
            'Score: $currentScore',
            style: TextStyle(color: Colors.white),
          ),
          // GAME CONTROLLERS
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: rotate,
                  icon: Icon(Icons.rotate_right),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: moveRight,
                  icon: Icon(Icons.arrow_forward_ios),
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
