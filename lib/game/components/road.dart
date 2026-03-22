import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../abschluss_game.dart';

class Road extends PositionComponent with HasGameReference<AbschlussGame> {
  double speed = 100.0;
  double roadOffset = 0.0;

  Sprite? roadSprite;
  double? textureAspectRatio;
  String roadTexturePath = 'road_texture.png';
  double scaleFactor = 1.2;

  Road() : super(position: Vector2.zero(), size: Vector2(1, 1), priority: -10);

  @override
  Future<void> onLoad() async {
    try {
      final image = await game.images.load(roadTexturePath);
      roadSprite = Sprite(image);
      final tw = image.width.toDouble();
      final th = image.height.toDouble();
      textureAspectRatio = th > 0 ? tw / th : 1.0;
    } catch (e) {
      roadSprite = null;
      textureAspectRatio = null;
    }
  }

  /// Aktuelle Spielfeldgröße (Fallback falls noch 0).
  Vector2 get currentSize {
    final s = game.size;
    if (s.x > 0 && s.y > 0) return s;
    return Vector2(400, 700);
  }

  double? get _scaledTextureHeight {
    if (textureAspectRatio == null || currentSize.x <= 0) return null;
    return (currentSize.x / textureAspectRatio!) * scaleFactor;
  }

  void updateSpeed(double newSpeed) {
    speed = newSpeed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = currentSize;

    final scaledTextureHeight = _scaledTextureHeight;
    if (roadSprite != null && scaledTextureHeight != null) {
      roadOffset += speed * dt;
      if (roadOffset >= scaledTextureHeight * 10) {
        roadOffset = roadOffset % scaledTextureHeight;
      }
    } else {
      roadOffset -= speed * dt;
      if (roadOffset < 0) roadOffset += 40;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return;

    final scaledTextureHeight = _scaledTextureHeight;
    if (roadSprite != null && scaledTextureHeight != null) {
      double normalizedOffset = roadOffset % scaledTextureHeight;
      if (normalizedOffset < 0) normalizedOffset += scaledTextureHeight;
      final scaledWidth = w * scaleFactor;
      final xOffset = (w - scaledWidth) / 2;
      double y = normalizedOffset - scaledTextureHeight;
      while (y < h) {
        roadSprite!.render(
          canvas,
          position: Vector2(xOffset, y),
          size: Vector2(scaledWidth, scaledTextureHeight),
        );
        y += scaledTextureHeight;
      }
    } else {
      // Fallback: gut sichtbare Straße ohne Textur
      final roadPaint = Paint()..color = const Color(0xFF4a5568);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), roadPaint);

      final borderPaint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 6;
      canvas.drawLine(Offset(0, 0), Offset(0, h), borderPaint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), borderPaint);

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3;
      final laneWidth = w / 4;
      for (int i = 1; i <= 3; i++) {
        final laneX = laneWidth * i; // 3 Trennlinien = 4 Spuren
        double y = roadOffset % 40;
        while (y < h) {
          canvas.drawLine(Offset(laneX, y), Offset(laneX, y + 20), linePaint);
          y += 40;
        }
      }
    }
  }
}
