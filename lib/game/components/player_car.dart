import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../abschluss_game.dart';
import 'enemy_car.dart';
import '../utils/placeholder_sprite.dart';

class PlayerCar extends SpriteComponent
    with HasGameReference<AbschlussGame>, CollisionCallbacks, KeyboardHandler {
  bool movingLeft = false;
  bool movingRight = false;
  // -1.0 = voll links, +1.0 = voll rechts (z.B. Gyro)
  double steerInput = 0.0;
  double moveSpeed = 300.0;
  static const double _digitalSteerFactor = 0.68; // Touch/Tastatur weniger aggressiv
  final String carTexture;

  /// Neigung beim Lenken (rad), wird weich interpoliert
  double _tiltAngle = 0.0;
  static const double _maxTilt = 0.18; // ~10° nach links/rechts
  static const double _tiltSpeed = 8.0; // wie schnell die Neigung folgt
  
  PlayerCar({
    required super.position,
    required super.size,
    required this.carTexture,
  });

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center; // Neigung dreht um die Mitte
    try {
      final image = await game.images.load(carTexture);
      sprite = Sprite(image);
    } catch (e) {
      sprite = await createPlaceholderSprite(Colors.blue);
      paint = Paint()..color = Colors.blue;
    }
  }
  
  void addCollision() {
    // Kollisions-Hitbox deutlich kleiner als die sichtbare Textur
    // (50% der Größe) für präzise Kollisionserkennung, die genau mit der Textur übereinstimmt
    final hitboxSize = size * 0.5;
    final hitboxOffset = (size - hitboxSize) / 2;
    add(RectangleHitbox(
      size: hitboxSize,
      position: hitboxOffset,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Grenzen: position ist Auto-Mitte (Anchor.center)
    const margin = 0.05;
    final minX = game.size.x * margin + size.x * 0.5;
    final maxX = game.size.x - game.size.x * margin - size.x * 0.5;

    final analog = steerInput.clamp(-1.0, 1.0);
    final hasAnalogInput = analog.abs() > 0.02;

    if (hasAnalogInput) {
      position.x += moveSpeed * analog * dt;
    } else {
      if (movingLeft && position.x > minX) {
        position.x -= moveSpeed * _digitalSteerFactor * dt;
      }
      if (movingRight && position.x < maxX) {
        position.x += moveSpeed * _digitalSteerFactor * dt;
      }
    }
    position.x = position.x.clamp(minX, maxX);

    // Lenk-Animation: Auto neigt sich in Fahrtrichtung
    final targetTilt = hasAnalogInput
        ? (_maxTilt * analog)
        : (movingLeft
              ? -_maxTilt
              : (movingRight ? _maxTilt : 0.0));
    _tiltAngle += (targetTilt - _tiltAngle) * (_tiltSpeed * dt).clamp(0.0, 1.0);
    angle = _tiltAngle;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    movingLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
                 keysPressed.contains(LogicalKeyboardKey.keyA);
    movingRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
                  keysPressed.contains(LogicalKeyboardKey.keyD);
    return true;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is EnemyCar) {
      game.gameOver();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
