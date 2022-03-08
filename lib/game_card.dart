import 'package:flutter/material.dart';
import 'package:page_flip_builder/page_flip_builder.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    Key? key,
    required this.flipKey,
    required this.canFlip,
    required this.hasFlutterLogo,
    this.flipDuration = const Duration(milliseconds: 250),
    this.onFlip,
  }) : super(key: key);

  final GlobalKey<PageFlipBuilderState> flipKey;
  final bool canFlip;
  final bool hasFlutterLogo;
  final Duration flipDuration;
  final ValueChanged<bool>? onFlip;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PageFlipBuilder(
        key: flipKey,
        nonInteractiveAnimationDuration: flipDuration,
        // only enable flip by tapping on the card
        interactiveFlipEnabled: false,
        // Show a card with '?' text inside it
        frontBuilder: (_) => GameCardSide(
          color: Colors.yellow[400],
          child: Text(
            '?',
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: canFlip ? () => flipKey.currentState?.flip() : null,
        ),
        // Show a card revealing the FlutterLogo or an empty container
        backBuilder: (_) => GameCardSide(
          child: hasFlutterLogo ? const FlutterLogo(size: 160) : Container(),
          color: Colors.white,
        ),
        onFlipComplete: onFlip,
      ),
    );
  }
}

class GameCardSide extends StatelessWidget {
  const GameCardSide({
    Key? key,
    required this.child,
    this.color,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 5,
        color: color,
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
