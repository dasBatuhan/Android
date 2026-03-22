import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../abschluss_game.dart';
import '../utils/placeholder_sprite.dart';

class EnemyCar extends SpriteComponent
    with HasGameReference<AbschlussGame>, CollisionCallbacks {
  bool markedForScore = false;

  // Spur 0 = enemy1, Spur 1 = enemy2, Spur 2 = enemy3
  static final List<String> carTextures = [
    'enemy1.png',
    'enemy2.png',
    'enemy3.png',
  ];

  final String texturePath;

  EnemyCar({
    required super.position,
    required super.size,
    required this.texturePath,
  });

  @override
  Future<void> onLoad() async {
    try {
      final image = await game.images.load(texturePath);
      sprite = Sprite(image);
    } catch (e) {
      final colors = [Colors.red, Colors.green, Colors.orange];
      final i = carTextures.indexOf(texturePath).clamp(0, 2);
      sprite = await createPlaceholderSprite(colors[i]);
      paint = Paint()..color = colors[i];
    }
  }

  void addCollision() {
    // An Referenz angepasst: Hitbox etwas kleiner, klar nach hinten (zur Mitte des Autos),
    // damit die Kollision nicht schon vor der sichtbaren Front auslöst
    final hitboxSize = size * 0.42;
    final hitboxOffset = (size - hitboxSize) / 2 + Vector2(0, size.y * 0.11);
    add(RectangleHitbox(
      size: hitboxSize,
      position: hitboxOffset,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Immer aktuelle Spielgeschwindigkeit nutzen, damit alle Gegner gleich schnell sind
    position.y += game.currentSpeed * dt;
    
    // Auto entfernen, wenn es außerhalb des Bildschirms ist
    if (position.y > game.size.y + 100) {
      removeFromParent();
    }
  }
}
