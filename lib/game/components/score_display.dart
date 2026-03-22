import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../abschluss_game.dart';

class _BonusPopup {
  _BonusPopup(this.points);

  final int points;
  double age = 0;

  static const double duration = 0.85;
}

/// HUD: Score + schwebende „+Punkte“ bei Near-Miss (Animation nach oben, ausblendend).
class ScoreDisplay extends Component with HasGameReference<AbschlussGame> {
  int currentScore = 0;

  final List<_BonusPopup> _bonuses = [];

  static const int _maxConcurrentBonuses = 4;

  void addNearMissBonus(int points) {
    if (points <= 0) return;
    _bonuses.add(_BonusPopup(points));
    while (_bonuses.length > _maxConcurrentBonuses) {
      _bonuses.removeAt(0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final b in _bonuses) {
      b.age += dt;
    }
    _bonuses.removeWhere((b) => b.age >= _BonusPopup.duration);
  }

  @override
  void render(Canvas canvas) {
    const baseX = 20.0;
    const baseY = 20.0;

    final scoreStyle = TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 4,
          color: Colors.black,
        ),
      ],
    );

    final scorePainter = TextPainter(
      text: TextSpan(text: 'Score: $currentScore', style: scoreStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    scorePainter.paint(canvas, const Offset(baseX, baseY));

    final startX = baseX + scorePainter.width + 12;

    for (var i = 0; i < _bonuses.length; i++) {
      final b = _bonuses[i];
      final t = (b.age / _BonusPopup.duration).clamp(0.0, 1.0);
      final ease = Curves.easeOut.transform(t);
      final opacity = (1.0 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
      final floatUp = -32 * ease;
      final popScale = 1.0 + 0.22 * (1.0 - ease);

      final bonusStyle = TextStyle(
        color: Color.lerp(
          const Color(0xFFFFEB3B),
          const Color(0xFF69F0AE),
          0.5,
        )!.withValues(alpha: opacity),
        fontSize: 22,
        fontWeight: FontWeight.w800,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 3,
            color: Colors.black.withValues(alpha: 0.85 * opacity),
          ),
        ],
      );

      final bonusPainter = TextPainter(
        text: TextSpan(text: '+${b.points}', style: bonusStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final y = baseY + 4 + floatUp + i * 6.0;

      final cx = startX + bonusPainter.width / 2;
      final cy = y + bonusPainter.height / 2;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(popScale);
      canvas.translate(-bonusPainter.width / 2, -bonusPainter.height / 2);
      bonusPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  void updateScore(int score) {
    currentScore = score;
  }
}
