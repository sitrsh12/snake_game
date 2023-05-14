import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _hasStarted= false;
  Animation<double>? _snakeAnimation;
  AnimationController? _snakeController;
  List _snake = [600, 601, 602, 603];
  final int _noOfSquares = 620;
  final Duration _duration = Duration(milliseconds: 500);
  final int _squareSize = 20;
  String? _currentSnakeDirection;
  int? _snakeFoodPosition;
  Random _random = new Random();

  @override
  void initState() {
    super.initState();
    _setUpGame();
  }

  void reStart() {
    setState(() {
      _snake = [600, 601, 602, 603];
      _hasStarted = false;
      _setUpGame();
    });
  }


  void _setUpGame() {
    _currentSnakeDirection = 'RIGHT';
    _hasStarted = true;
    do {
      _snakeFoodPosition = _random.nextInt(_noOfSquares);
    } while (_snake.contains(_snakeFoodPosition));
    _snakeController = AnimationController(vsync: this, duration: _duration);
    _snakeAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _snakeController!);
  }
  Duration delay = const Duration(milliseconds: 200);
  // void _gameStart() {
  //   Timer.periodic(delay, (Timer timer) {
  //         delay += const Duration(milliseconds: 200);
  //         timer.cancel();
  //         timer = Timer.periodic(delay, (timer) {
  //           _updateSnake();
  //         });
  //     if (_hasStarted) timer.cancel();
  //   });
  // }

  void _gameStart() {
    Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      _updateSnake();
      if (_hasStarted) timer.cancel();
    });
  }




  void gameOver(){
    reStart();
    gameOverDialog(context);
  }

  void _updateSnake() {
    if (!_hasStarted) {
      setState(() {
        switch (_currentSnakeDirection) {
          case 'DOWN':
            if (_snake.last > _noOfSquares) {
              gameOver();
            }
            else {
              _snake.add(_snake.last + _squareSize);
            }
            break;
          case 'UP':
            if (_snake.last < _squareSize) {
              gameOver();
            } else {
              _snake.add(_snake.last - _squareSize);
            }
            break;
          case 'RIGHT':
            if ((_snake.last + 1) % _squareSize == 0) {
              gameOver();
            } else {
              _snake.add(_snake.last + 1);
            }
            break;
          case 'LEFT':
            if ((_snake.last) % _squareSize == 0) {
              gameOver();
            } else {
              _snake.add(_snake.last - 1);
            }
        }

        if (_snake.last != _snakeFoodPosition) {
          _snake.removeAt(0);
        } else {
          do {
            _snakeFoodPosition = _random.nextInt(_noOfSquares);
          } while (
          _snake.contains(_snakeFoodPosition)
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game',
            style: TextStyle(color: Colors.white, fontSize: 20.0)),
        centerTitle: false,
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue,
          elevation: 15,
          label: Text(
            _hasStarted ? 'Start' : 'Pause',
            style: const TextStyle(),
          ),
          onPressed: () {
            setState(() {
              if (_hasStarted) {
                _snakeController?.forward();
              } else {
                _snakeController?.reverse();
              }
              _hasStarted = !_hasStarted;
              _gameStart();
            });
          },
          icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _snakeAnimation!
          )),
      body: SizedBox(
        height: 620,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            child: Center(
              child: GestureDetector(
                onVerticalDragUpdate: (drag) {
                  if (drag.delta.dy > 0 && _currentSnakeDirection != 'UP') {
                    _currentSnakeDirection = 'DOWN';
                  } else if (drag.delta.dy < 0 && _currentSnakeDirection != 'DOWN') {
                    _currentSnakeDirection = 'UP';
                  }
                },
                onHorizontalDragUpdate: (drag) {
                  if (drag.delta.dx > 0 && _currentSnakeDirection != 'LEFT') {
                    _currentSnakeDirection = 'RIGHT';
                  } else if (drag.delta.dx < 0 && _currentSnakeDirection != 'RIGHT') {
                    _currentSnakeDirection = 'LEFT';
                  }
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                    itemCount: _squareSize + _noOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _squareSize),
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: Container(
                          padding: _snake.contains(index)
                              ? const EdgeInsets.all(1)
                              : const EdgeInsets.all(0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                                color: _snake.contains(index)
                                    ? Colors.black
                                    : index == _snakeFoodPosition
                                        ? Colors.redAccent
                                        : Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  gameOverDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(
                        Icons.app_registration,
                        size: 40,
                      ),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 10, 20, 10),
                  child: Text(
                    "Game Over",
                    style: TextStyle(color: Colors.orange, fontSize: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Colors.blueGrey,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                        reStart();
                      },
                      child: const Text("Play Again",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
