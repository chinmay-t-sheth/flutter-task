import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    GuessNumberGame(),
    TapChallengeGame(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? guessScore = prefs.getInt('guess_score');
    int? tapScore = prefs.getInt('tap_score');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Scores'),
        content: Text('Guess Number: ${guessScore ?? 0}\nTap Challenge: ${tapScore ?? 0}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games'),
        actions: [
          IconButton(icon: Icon(Icons.score), onPressed: _showScores),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Guess Number'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Tap Challenge'),
        ],
      ),
    );
  }
}

// Tab 1: Guess Number Game
class GuessNumberGame extends StatefulWidget {
  @override
  _GuessNumberGameState createState() => _GuessNumberGameState();
}

class _GuessNumberGameState extends State<GuessNumberGame> {
  final TextEditingController _guessController = TextEditingController();
  late int _targetNumber;
  int _attempts = 0;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _generateNumber();
  }

  void _generateNumber() {
    _targetNumber = Random().nextInt(25) + 1;
    _attempts = 0;
    _message = 'Guess the number between 1 and 25';
  }

  Future<void> _checkGuess() async {
    if (_attempts >= 5) return;

    int? guess = int.tryParse(_guessController.text);
    if (guess == null) return;

    setState(() {
      _attempts++;
      if (guess == _targetNumber) {
        _message = '🎉 You are Winner! Number: $_targetNumber';
        _saveScore(1);
      } else if (_attempts >= 5) {
        _message = '❌ You lost! Number was $_targetNumber';
        _saveScore(0);
      } else if (guess < _targetNumber) {
        _message = 'Try higher! Attempts left: ${5 - _attempts}';
      } else {
        _message = 'Try lower! Attempts left: ${5 - _attempts}';
      }
    });
  }

  Future<void> _saveScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('guess_score', score);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_message, style: TextStyle(fontSize: 18)),
          TextField(controller: _guessController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Enter your guess')),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _checkGuess, child: Text('Submit Guess')),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _generateNumber, child: Text('Reset Game')),
        ],
      ),
    );
  }
}

// Tab 2: Tap Challenge Game
class TapChallengeGame extends StatefulWidget {
  @override
  _TapChallengeGameState createState() => _TapChallengeGameState();
}

class _TapChallengeGameState extends State<TapChallengeGame> {
  int _score = 0;
  int _timeLeft = 10;
  Timer? _timer;
  bool _gameStarted = false;

  void _startGame() {
    _gameStarted = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _saveScore();
        }
      });
    });
  }

  void _tapButton() {
    if (!_gameStarted) {
      _startGame();
    }
    if (_timeLeft > 0) {
      setState(() {
        _score++;
      });
    }
  }

  Future<void> _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tap_score', _score);
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _timeLeft = 10;
      _gameStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Time Left: $_timeLeft s', style: TextStyle(fontSize: 22)),
          Text('Score: $_score', style: TextStyle(fontSize: 22)),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _tapButton, child: Text('TAP ME')), 
          SizedBox(height: 20),
          ElevatedButton(onPressed: _resetGame, child: Text('Reset Game')),
        ],
      ),
    );
  }
}
