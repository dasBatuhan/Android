import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Erstellt ein einfarbiges 2x2-Sprite als Platzhalter, wenn eine Textur nicht geladen werden kann.
/// SpriteComponent verlangt immer ein gesetztes [sprite].
Future<Sprite> createPlaceholderSprite(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, 2, 2),
    ui.Paint()..color = color,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 2);
  return Sprite(image);
}
