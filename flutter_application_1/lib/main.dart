import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(HangmanGame());
}

class HangmanGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hangman Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<String> _wordList = [
    'FLUTTER',
    'ANDROID',
    'MOBILE',
    'DART',
    'WIDGET',
    'SCAFFOLD',
    'MATERIAL',
    'CONTAINER',
    'COLUMN',
    'STACK',
    'PADDING',
    'APPLICATION',
    'DEVELOPMENT',
    'FRAMEWORK',
    'BUILDER',
    'ANIMATION',
    'GESTURE',
    'STATEFUL',
    'STATELESS',
    'NAVIGATOR',
    'ROUTE',
    'THEME',
    'CONTEXT',
    'POSITION',
    'LAYOUT',
    'OVERFLOW',
  ];

  late String _currentWord;
  late List<String> _guessedLetters;
  late int _wrongGuesses;
  late int _score;
  late int _highScore;
  late bool _gameOver;
  late bool _gameWon;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _highScore = 0;
    _initializeGame();

    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _currentWord = _wordList[Random().nextInt(_wordList.length)];
    _guessedLetters = [];
    _wrongGuesses = 0;
    _score = 0;
    _gameOver = false;
    _gameWon = false;
  }

  void _guessLetter(String letter) {
    if (_gameOver || _guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);

      if (!_currentWord.contains(letter)) {
        _wrongGuesses++;
        _shakeController.forward();

        if (_wrongGuesses >= 6) {
          _gameOver = true;
        }
      } else {
        bool wordComplete = true;
        for (int i = 0; i < _currentWord.length; i++) {
          if (!_guessedLetters.contains(_currentWord[i])) {
            wordComplete = false;
            break;
          }
        }

        if (wordComplete) {
          _gameWon = true;
          _gameOver = true;
          _score += 10 + (10 - _wrongGuesses) * 5;
          if (_score > _highScore) {
            _highScore = _score;
          }
        }
      }
    });
  }

  void _playAgain() {
    setState(() {
      _currentWord = _wordList[Random().nextInt(_wordList.length)];
      _guessedLetters = [];
      _wrongGuesses = 0;
      _gameOver = false;
      _gameWon = false;
    });
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        title: Text('Hangman Game'),
        backgroundColor: Colors.indigo,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $_score | High: $_highScore',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _wrongGuesses > 0 ? sin(_shakeAnimation.value) * 5 : 0,
                      0,
                    ),
                    child: child,
                  );
                },
                child: CustomPaint(
                  painter: HangmanPainter(wrongGuesses: _wrongGuesses),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _currentWord.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    width: 30.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child:
                        _guessedLetters.contains(_currentWord[index]) ||
                                _gameOver
                            ? Text(
                              _currentWord[index],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : Text(''),
                  ),
                ),
              ),
            ),
          ),

          if (_gameOver)
            Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    _gameWon ? 'Congratulations! You won!' : 'Game Over!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _gameWon ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _playAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text('Play Again'),
                  ),
                  SizedBox(height: 10),
                  TextButton(onPressed: _resetGame, child: Text('Reset Score')),
                ],
              ),
            ),

          if (!_gameOver)
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildKeyboardRow('QWERTYUIOP'),
                    _buildKeyboardRow('ASDFGHJKL'),
                    _buildKeyboardRow('ZXCVBNM'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(String letters) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            letters.split('').map((letter) {
              bool isGuessed = _guessedLetters.contains(letter);
              bool isCorrect = _currentWord.contains(letter);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.0),
                child: Material(
                  color:
                      isGuessed
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.indigo,
                  borderRadius: BorderRadius.circular(8.0),
                  child: InkWell(
                    onTap: isGuessed ? null : () => _guessLetter(letter),
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      width: 32.0,
                      height: 45.0,
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int wrongGuesses;

  HangmanPainter({required this.wrongGuesses});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double baseY = size.height * 0.8;
    final double topY = size.height * 0.2;
    final double headRadius = size.height * 0.08;

    if (wrongGuesses > 0) {
      canvas.drawLine(
        Offset(centerX - 100, baseY),
        Offset(centerX + 100, baseY),
        paint,
      );
    }

    if (wrongGuesses > 1) {
      canvas.drawLine(
        Offset(centerX - 50, baseY),
        Offset(centerX - 50, topY),
        paint,
      );
    }

    if (wrongGuesses > 2) {
      canvas.drawLine(
        Offset(centerX - 50, topY),
        Offset(centerX + 50, topY),
        paint,
      );
    }

    if (wrongGuesses > 3) {
      canvas.drawLine(
        Offset(centerX + 50, topY),
        Offset(centerX + 50, topY + 40),
        paint,
      );
    }

    if (wrongGuesses > 4) {
      canvas.drawCircle(
        Offset(centerX + 50, topY + 40 + headRadius),
        headRadius,
        paint,
      );
    }

    if (wrongGuesses > 5) {
      canvas.drawLine(
        Offset(centerX + 50, topY + 40 + headRadius * 2),
        Offset(centerX + 50, topY + 40 + headRadius * 2 + 70),
        paint,
      );

      canvas.drawLine(
        Offset(centerX + 50, topY + 40 + headRadius * 2 + 20),
        Offset(centerX + 50 - 40, topY + 40 + headRadius * 2 + 10),
        paint,
      );

      canvas.drawLine(
        Offset(centerX + 50, topY + 40 + headRadius * 2 + 20),
        Offset(centerX + 50 + 40, topY + 40 + headRadius * 2 + 10),
        paint,
      );

      canvas.drawLine(
        Offset(centerX + 50, topY + 40 + headRadius * 2 + 70),
        Offset(centerX + 50 - 30, topY + 40 + headRadius * 2 + 120),
        paint,
      );

      canvas.drawLine(
        Offset(centerX + 50, topY + 40 + headRadius * 2 + 70),
        Offset(centerX + 50 + 30, topY + 40 + headRadius * 2 + 120),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
