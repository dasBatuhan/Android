import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/player_car.dart';
import 'components/enemy_car.dart';
import 'components/road.dart';
import 'components/score_display.dart';
import 'components/gyro_controls.dart';
import '../services/score_service.dart';

/// Hauptspiel-Klasse für das Abschluss-Projekt
class AbschlussGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final String playerName;
  final String controlMode;

  AbschlussGame({
    required this.playerName,
    required this.controlMode,
  });

  // Spielvariablen
  late PlayerCar player;
  late Road road;
  late ScoreDisplay scoreDisplay;
  
  int score = 0;
  double _scoreBuffer = 0.0;
  double baseSpeed = 100.0;
  double currentSpeed = 100.0;
  double enemySpawnTimer = 0.0;
  double enemySpawnInterval = 2.0;
  double playTime = 0.0; // Sekunden überlebt (für Multiplikator)
  
  bool isGameOver = false;
  bool _layoutDone = false;
  bool _onLoadDone = false;

  String selectedCarTexture = 'player_car_1.png';

  @override
  Future<void> onLoad() async {
    // Lade ausgewählte Auto-Textur (nur Dateiname; Flame-Prefix ist assets/images/)
    String car = await ScoreService.getSelectedCar();
    selectedCarTexture = car.contains('/') ? car.split('/').last : car;
    
    // Kamera: sichtbare Größe + Fokus auf Spielfeldmitte (sonst ist (0,0) in der Bildschirmmitte)
    camera.viewfinder.visibleGameSize = size;
    final camCenterX = size.x > 0 ? size.x / 2 : 200.0;
    final camCenterY = size.y > 0 ? size.y / 2 : 350.0;
    camera.viewfinder.position = Vector2(camCenterX, camCenterY);

    // Wichtig: Komponenten zur WORLD hinzufügen, nicht zum Game –
    // die Kamera rendert nur den Inhalt der Welt.
    road = Road();
    await world.add(road);

    final w = size.x > 0 ? size.x : 400.0;
    final h = size.y > 0 ? size.y : 700.0;
    final carWidth = w * 0.25;
    final carHeight = carWidth * 1.6;
    player = PlayerCar(
      position: Vector2(w / 2, h * 0.65),
      size: Vector2(carWidth, carHeight),
      carTexture: selectedCarTexture,
    );
    await world.add(player);

    scoreDisplay = ScoreDisplay();
    await camera.viewfinder.add(scoreDisplay); // HUD: immer vor der Welt/Autos

    if (controlMode == ScoreService.controlModeGyro) {
      await world.add(GyroControls());
    }
    
    // Kollisionserkennung für Spieler aktivieren
    player.addCollision();
    _onLoadDone = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isGameOver) return;

    playTime += dt;
    // Geschwindigkeit steigt mit Spielzeit (nicht mit Score)
    currentSpeed = baseSpeed + (playTime * 8);
    road.updateSpeed(currentSpeed);

    enemySpawnTimer += dt;
    if (enemySpawnTimer >= enemySpawnInterval) {
      if (spawnEnemy()) enemySpawnTimer = 0.0;
      enemySpawnInterval = (2.0 - (playTime * 0.035)).clamp(0.45, 2.0);
    }

    updateScore(dt);
    scoreDisplay.updateScore(score);
  }
  
  /// Spawnt einen Gegner nur wenn oben genug Abstand. Gibt true zurück wenn gespawnt wurde.
  bool spawnEnemy() {
    const minGap = 40.0; // Nur blockieren wenn Gegner direkt im Spawn-Bereich
    for (final e in world.children.whereType<EnemyCar>()) {
      if (e.position.y < minGap) return false;
    }

    final sx = size.x > 0 ? size.x : 400.0;
    final carWidth = sx * 0.25;
    final carHeight = carWidth * 1.6;
    final laneIndex = Random().nextInt(4);
    final enemyTypeIndex = Random().nextInt(3);
    const roadMargin = 0.12;
    final roadWidth = sx * (1.0 - 2 * roadMargin);
    final laneWidth = roadWidth / 4;
    final laneCenterX = sx * roadMargin + laneWidth * 0.5 + laneIndex * laneWidth;
    final spawnX = laneCenterX - carWidth * 0.5;

    final enemy = EnemyCar(
      position: Vector2(spawnX, -carHeight - 80),
      size: Vector2(carWidth, carHeight),
      texturePath: EnemyCar.carTextures[enemyTypeIndex],
    );
    enemy.addCollision();
    world.add(enemy);
    return true;
  }
  
  void updateScore(double dt) {
    // Multiplikator: je länger man überlebt und je schneller es wird, desto mehr Punkte
    final speedMultiplier = (currentSpeed / baseSpeed).clamp(1.0, 5.0);

    // Überlebens-Punkte pro Sekunde, skaliert mit Multiplikator.
    // Buffer verhindert "ruckelige" Rundung am Anfang.
    const basePointsPerSecond = 6.0;
    _scoreBuffer += dt * basePointsPerSecond * speedMultiplier;

    // Gegner sind in der World, nicht direkt unter dem Game
    final enemies = world.children.whereType<EnemyCar>().toList();

    // Beim ersten Frames kann size.x noch 0 sein → laneWidth wäre 0 → nie „nah genug“.
    // Gleiche Referenzbreite wie in onLoad / sinnvoller Fallback.
    final layoutW = size.x > 0 ? size.x : 400.0;
    const roadMargin = 0.12;
    final roadLaneWidth = layoutW * (1.0 - 2 * roadMargin) / 4;
    // Echte Spurbreite wie beim Spawn; etwas tolerant für benachbarte Spur
    final horizontalCloseLimit = roadLaneWidth * 1.22;

    for (final enemy in enemies) {
      if (enemy.markedForScore) continue;

      final horizontalDistance = (enemy.position.x - player.position.x).abs();
      final verticalDistance = enemy.position.y - player.position.y;

      // Etwas großzügiger, damit Near-Miss bei langsamer Anfangsgeschwindigkeit nicht verpasst wird
      final isNearVertically = verticalDistance.abs() < 145;
      final hasJustPassed = verticalDistance > 0 && verticalDistance < 105;

      final isCloseHorizontally = horizontalDistance < horizontalCloseLimit;

      if (isCloseHorizontally && (isNearVertically || hasJustPassed)) {
        // Je näher am Gegner vorbei, desto mehr Punkte (max 50 Basis)
        final proximityFactor =
            1.0 - (horizontalDistance / horizontalCloseLimit).clamp(0.0, 1.0);
        final nearMissPoints = (25 + (25 * proximityFactor)).round();
        final bonusAdded = nearMissPoints * speedMultiplier;
        _scoreBuffer += bonusAdded;
        enemy.markedForScore = true;
        scoreDisplay.addNearMissBonus(bonusAdded.round());
      }
    }

    score = _scoreBuffer.floor();
  }
  
  bool isNewHighscore = false;

  void setTouchSteering({required bool left, required bool right}) {
    if (!_onLoadDone || isGameOver) return;
    player.steerInput = 0.0;
    player.movingLeft = left;
    player.movingRight = right;
  }

  void stopTouchSteering() {
    if (!_onLoadDone) return;
    player.steerInput = 0.0;
    player.movingLeft = false;
    player.movingRight = false;
  }

  void gameOver() async {
    isGameOver = true;
    // Ergebnis in der Highscore-Datenbank speichern (inkl. Spielernamen)
    isNewHighscore = await ScoreService.savePlayScore(
      playerName: playerName,
      score: score,
    );
    pauseEngine();
    overlays.add('gameOver');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera.viewfinder.visibleGameSize = size;
    // Kamera auf Spielfeldmitte zentrieren, damit (0,0)–(size.x, size.y) den ganzen Bildschirm füllt
    if (size.x > 0 && size.y > 0) {
      camera.viewfinder.position = Vector2(size.x / 2, size.y / 2);
    }
    // Spieler erst zentrieren, wenn onLoad fertig ist (onGameResize kann vor onLoad laufen)
    if (_onLoadDone && !_layoutDone && size.x > 0 && size.y > 0) {
      _layoutDone = true;
      player.position = Vector2(size.x / 2, size.y * 0.65);
      player.size = Vector2(size.x * 0.25, size.x * 0.25 * 1.6);
    }
  }

  @override
  Color backgroundColor() {
    return const Color(0xFF2c3e50);
  }
}
