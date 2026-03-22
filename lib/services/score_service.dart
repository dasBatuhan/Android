import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  final String playerName;
  final int score;
  final DateTime playedAt;

  const ScoreEntry({
    required this.playerName,
    required this.score,
    required this.playedAt,
  });

  static ScoreEntry fromMap(Map<String, dynamic> map) {
    final playerName = (map['playerName'] as String?) ?? 'Unbekannt';
    final score = (map['score'] as num?)?.toInt() ?? 0;
    final playedAtMillis = (map['playedAtMillis'] as num?)?.toInt() ?? 0;
    return ScoreEntry(
      playerName: playerName,
      score: score,
      playedAt: DateTime.fromMillisecondsSinceEpoch(playedAtMillis),
    );
  }

  Map<String, dynamic> toMap() => {
        'playerName': playerName,
        'score': score,
        'playedAtMillis': playedAt.millisecondsSinceEpoch,
      };
}

/// Lokale "Datenbank" für Highscores und die letzten 3 Spielstände.
///
/// Implementiert mit Hive, weil es (ähnlich wie eine DB) lokal persistiert
/// und auf Web sowie Desktop funktioniert.
class ScoreService {
  static const String controlModeTouch = 'touch';
  static const String controlModeGyro = 'gyro';

  static const String _boxName = 'abschluss_score_db';
  static const String _highscoresKey = 'highscores';
  static const String _lastPlaysKey = 'lastPlays';
  /// Nur die drei besten Einträge dauerhaft speichern.
  static const int _maxHighscores = 3;

  // SharedPreferences: nur fürs Menu-UI-Setup (Spielername, Autoauswahl)
  static const String _selectedCarKey = 'selected_car';
  static const String _playerNameKey = 'player_name';
  static const String _controlModeKey = 'control_mode';

  static const List<String> _validCars = [
    'player_car_1.png',
    'player_car_2.png',
    'player_car_3.png',
  ];

  static Box<dynamic>? _box;

  /// Muss einmal beim App-Start aufgerufen werden.
  static Future<void> initDatabase() async {
    await Hive.initFlutter();
    _box ??= await Hive.openBox(_boxName);
  }

  static Future<void> _ensureInit() async {
    if (_box != null) return;
    await initDatabase();
  }

  static List<ScoreEntry> _decodeEntries(String? raw) {
    // Wichtig für Web: `const []` ist ein unmodifiable List -> `sort()` wirft dann
    // `Unsupported operation: sort`. Deshalb immer eine growable List zurückgeben.
    if (raw == null || raw.isEmpty) return <ScoreEntry>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <ScoreEntry>[];

    return decoded
        .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
        .map(ScoreEntry.fromMap)
        .toList(growable: true);
  }

  static String _encodeEntries(List<ScoreEntry> entries) {
    return jsonEncode(entries.map((e) => e.toMap()).toList());
  }

  static int _bestScoreOf(List<ScoreEntry> highscores) {
    if (highscores.isEmpty) return 0;
    highscores.sort((a, b) {
      final s = b.score.compareTo(a.score);
      if (s != 0) return s;
      return b.playedAt.compareTo(a.playedAt);
    });
    return highscores.first.score;
  }

  /// Top-Highscores (absteigend nach Score).
  static Future<List<ScoreEntry>> getTopHighscores({int limit = 5}) async {
    await _ensureInit();
    final raw = _box!.get(_highscoresKey) as String?;
    final entries = _decodeEntries(raw);
    if (kDebugMode) {
      debugPrint('ScoreService: load highscores raw isNull=${raw == null}');
    }

    // Sortierung: Score desc, bei Gleichstand neuere zuerst
    entries.sort((a, b) {
      final s = b.score.compareTo(a.score);
      if (s != 0) return s;
      return b.playedAt.compareTo(a.playedAt);
    });

    final l = limit.clamp(0, 100);
    return entries.take(l).toList();
  }

  /// Best Score (über alle Spieler).
  static Future<int> getBestScore() async {
    final highscores = await getTopHighscores(limit: _maxHighscores);
    return _bestScoreOf(highscores);
  }

  /// Speichert das Ergebnis für einen Spieler:
  /// - Highscore-Liste aktualisieren (nur die drei besten behalten)
  /// - Letzte 3 Spielstände aktualisieren (chronologisch absteigend)
  ///
  /// Rückgabe: `true`, wenn das Ergebnis neuer Best-Score war.
  static Future<bool> savePlayScore({
    required String playerName,
    required int score,
  }) async {
    await _ensureInit();

    final now = DateTime.now();
    final entry = ScoreEntry(playerName: playerName, score: score, playedAt: now);

    final highscoresRaw = _box!.get(_highscoresKey) as String?;
    final lastRaw = _box!.get(_lastPlaysKey) as String?;

    final highscores = _decodeEntries(highscoresRaw).toList();
    final lastPlays = _decodeEntries(lastRaw).toList();

    final bestBefore = _bestScoreOf(highscores);
    final isNewHighscore = score > bestBefore;

    highscores.add(entry);
    // Score desc, bei Gleichstand neuere zuerst
    highscores.sort((a, b) {
      final s = b.score.compareTo(a.score);
      if (s != 0) return s;
      return b.playedAt.compareTo(a.playedAt);
    });
    final trimmedHighscores = highscores.take(_maxHighscores).toList();
    // Auf Web ist das Speichern async (IndexedDB). Wir warten, damit es auch
    // bei schnellem Schließen nach Game Over zuverlässig persistiert.
    await _box!.put(_highscoresKey, _encodeEntries(trimmedHighscores));

    // Last plays: neueste zuerst
    lastPlays.insert(0, entry);
    lastPlays.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    final trimmedLastPlays = lastPlays.take(3).toList();
    await _box!.put(_lastPlaysKey, _encodeEntries(trimmedLastPlays));
    await _box!.flush();

    if (kDebugMode) {
      final savedHigh = _box!.get(_highscoresKey);
      final savedLast = _box!.get(_lastPlaysKey);
      debugPrint(
        'ScoreService: saved highscores=${savedHigh != null}, lastPlays=${savedLast != null}',
      );
    }

    return isNewHighscore;
  }

  /// Letzte Spielstände (max `limit`, Default 3).
  static Future<List<ScoreEntry>> getLastPlays({int limit = 3}) async {
    await _ensureInit();
    final raw = _box!.get(_lastPlaysKey) as String?;
    final entries = _decodeEntries(raw);

    entries.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    final l = limit.clamp(0, 100);
    return entries.take(l).toList();
  }

  // Ausgewähltes Auto speichern
  static Future<void> saveSelectedCar(String carTexture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCarKey, carTexture);
  }

  // Ausgewähltes Auto laden
  static Future<String> getSelectedCar() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_selectedCarKey);
    if (saved != null && _validCars.contains(saved)) return saved;
    return 'player_car_1.png';
  }

  /// Spielername fürs Menu (damit man nicht jedes Mal neu tippt).
  static Future<String> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_playerNameKey);
    if (saved == null || saved.trim().isEmpty) return '';
    return saved.trim();
  }

  static Future<void> savePlayerName(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, playerName.trim());
  }

  /// Gewählte Steuerung speichern: `touch` oder `gyro`.
  static Future<void> saveControlMode(String controlMode) async {
    final mode = (controlMode == controlModeGyro)
        ? controlModeGyro
        : controlModeTouch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_controlModeKey, mode);
  }

  /// Gewählte Steuerung laden (Default: touch).
  static Future<String> getControlMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_controlModeKey);
    if (saved == controlModeGyro) return controlModeGyro;
    return controlModeTouch;
  }
}

