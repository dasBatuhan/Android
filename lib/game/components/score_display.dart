import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../abschluss_game.dart';

class ScoreDisplay extends Component with HasGameReference<AbschlussGame> {
  int currentScore = 0;
  
  @override
  void render(Canvas canvas) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 4,
          color: Colors.black,
        ),
      ],
    );
    
    final textSpan = TextSpan(
      text: 'Score: $currentScore',
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(20, 20));
  }
  
  void updateScore(int score) {
    currentScore = score;
  }
}

