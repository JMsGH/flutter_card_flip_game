import 'dart:math';

import 'package:card_flip_game_challenge/game_card.dart';
import 'package:flutter/material.dart';
import 'package:page_flip_builder/page_flip_builder.dart';

enum GameStatus {
  playing,
  notPlaying,
  restarting,
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static final _rng = Random();
  static const cardFlipDuration = Duration(milliseconds: 350);
  // 0 か 1 を出す
  int _targetIndex = _rng.nextInt(2);

  // whether the game is currently playing (both cards are not turned)
  GameStatus _gameStatus = GameStatus.playing;
  // whether the player won the game (found the Flutter logo)
  bool _didWin = false;

  // flip key for first card
  final _flipKey0 = GlobalKey<PageFlipBuilderState>();
  // flip key for second card
  final _flipKey1 = GlobalKey<PageFlipBuilderState>();

  // bool didWinには、_targetIndexが0のときに1枚目のカードをめくったときと
  // _targetIndexが１のときに2枚目のカードをめくったときに true が入る
  void _completeGame(bool didWin) {
    setState(() {
      _didWin = didWin;
      _gameStatus = GameStatus.notPlaying;
    });
  }

  Future<void> _tryAgain() async {
    setState(() {
      _gameStatus == GameStatus.restarting;
    });
    // hide again the flipped card
    // which key to use depends on these variables:
    if (_didWin && _targetIndex == 0 || !_didWin && _targetIndex == 1) {
      _flipKey0.currentState?.flip();
    } else {
      _flipKey1.currentState?.flip();
    }
    //await until the card is flipped before changing the state
    // (and revealing the new position)
    await Future.delayed(cardFlipDuration);
    setState(() {
      _targetIndex = _rng.nextInt(2);
      _gameStatus = GameStatus.playing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutterロゴを探せ'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // first card
                GameCard(
                  flipKey: _flipKey0,
                  canFlip: _gameStatus == GameStatus.playing,
                  hasFlutterLogo: _targetIndex == 0,
                  flipDuration: cardFlipDuration,
                  onFlip: (frontSide) {
                    if (!frontSide) {
                      _completeGame(_targetIndex == 0);
                    }
                  },
                ),
                const SizedBox(height: 10),

                GameCard(
                  flipKey: _flipKey1,
                  canFlip: _gameStatus == GameStatus.playing,
                  hasFlutterLogo: _targetIndex == 1,
                  flipDuration: cardFlipDuration,
                  onFlip: (frontSide) {
                    if (!frontSide) {
                      _completeGame(_targetIndex == 1);
                    }
                  },
                ),
                // retry/end game UI
                const SizedBox(height: 20),
                RetryGameWidget(
                  gameStatus: _gameStatus,
                  won: _didWin,
                  onRetry: _tryAgain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RetryGameWidget extends StatelessWidget {
  const RetryGameWidget({
    Key? key,
    required this.gameStatus,
    required this.won,
    this.onRetry,
  }) : super(key: key);

  final GameStatus gameStatus;
  final bool won;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // ignore any clicks if game is playing or restarting
      ignoring: gameStatus != GameStatus.notPlaying,
      child: AnimatedOpacity(
        opacity: gameStatus == GameStatus.playing ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Text(
              won ? 'あなたの勝ち！' : 'あなたの負け！',
              style: Theme.of(context).textTheme.headline5!.copyWith(
                  color: won ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(width: 2, color: Colors.black54),
              ),
              onPressed: onRetry,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'もう1回やる',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
