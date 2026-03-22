# Racing Game – Projekt-Dokumentation

Dieses Dokument beschreibt alle im Projekt umgesetzten Funktionen und wie der Code aufgebaut ist.

---

## 1. Überblick

**Technologie:** Flutter mit Flame-Engine (2D-Spiel)  
**Spiel:** Top-Down-Rennspiel mit 4 Spuren, Spieler-Auto, Gegner-Autos, Score und persistenter Speicherung.

**Struktur:**
- `main.dart` – App-Start, Menü & Game-Screen
- `screens/menu_screen.dart` – Startbildschirm mit Auto-Auswahl
- `game/abschluss_game.dart` – Hauptspiel-Logik (FlameGame)
- `game/components/` – Road, PlayerCar, EnemyCar, ScoreDisplay, TouchControls, GyroControls, GameOverOverlay
- `game/components/` – Road, PlayerCar, EnemyCar, ScoreDisplay, GyroControls, ControlOverlay, GameOverOverlay
- `game/utils/placeholder_sprite.dart` – Platzhalter-Sprite bei fehlenden Bildern
- `services/score_service.dart` – Highscores/Letzte 3 (Hive) + Spielername/Autoauswahl (SharedPreferences)

---

## 2. main.dart

### Funktionen
- **`main()`**  
  - `WidgetsFlutterBinding.ensureInitialized()`  
  - `await ScoreService.initDatabase()` – initialisiert die lokale Hive-"Datenbank"  
  - `runApp(MyApp())` – startet die App.

- **`MyApp`**  
  - `MaterialApp` mit Startseite `MenuScreen`, Theme.

- **`GameScreen`**  
  - Zeigt das Spiel in einem `GameWidget<AbschlussGame>.controlled`.
  - **`overlayBuilderMap: 'gameOver'`** – bei Game Over wird `GameOverOverlayWidget` gezeichnet (Score, „Zurück zum Menü“).

---

## 3. Menü (screens/menu_screen.dart)

### State
- `bestScore` – angezeigter Best Score (Top-Score aus ScoreService).
- `selectedCar` – aktuell gewähltes Auto (z. B. `player_car_1.png`).
- `_hoveredCar` – Textur des Autos, über dem die Maus gerade ist (für Hover-Effekt).
- `_playerName` – eingegebener Spielername (Pflichtfeld).
- `_topHighscores` – Liste der gespeicherten Highscores (Top 3).
- `_lastPlays` – Liste der letzten 3 Spielstände.
- `_controlMode` – gewählte Steuerung (`touch` oder `gyro`).

### Auto-Liste
- `availableCars`: 3 Optionen – `player_car_1.png`, `player_car_2.png`, `player_car_3.png` (ohne „Auto 4“).

### Funktionen
- **`_loadData()`**  
  Lädt u. a. `ScoreService.getBestScore()`, `ScoreService.getSelectedCar()`, `ScoreService.getPlayerName()`, außerdem:
  - `ScoreService.getTopHighscores(limit: 3)`
  - `ScoreService.getLastPlays(limit: 3)`
  und setzt die UI per `setState`.

- **`_selectCar(String texture)`**  
  Speichert die Auswahl mit `ScoreService.saveSelectedCar(texture)` und setzt `selectedCar`.

- **`_startGame()`**  
  1. Prüft, ob der Name nicht leer ist.
  2. Speichert den Namen mit `ScoreService.savePlayerName(trimmedName)`.
  3. Speichert zusätzlich die gewählte Steuerung mit `ScoreService.saveControlMode(...)`.
  4. Öffnet das Spiel: `GameScreen(playerName: trimmedName, controlMode: ...)`.
  5. Nach Rückkehr ins Menü wird `_loadData()` ausgeführt.

### UI
- Hintergrund: Straßen-Textur `assets/images/road_texture.png` + dunkler Gradient.
- Titel: „Racing Game“.
- Pflichtfeld:
  - `TextField` „Dein Name“
  - `Start` deaktiviert, solange `_playerName.trim().isEmpty` ist
- Best-Score-Box mit gelber Zahl.
- **Auto-Auswahl:** Nur Bilder (130×130), kein Rahmen, kein Text, kein Häkchen.
  - **Hover:** `AnimatedScale` 1.08.
  - **Ausgewählt:** dauerhaft Scale 1.35.
- Zusätzlich: Anzeige von Highscores (Top 3) und „Letzte 3 Spiele“ mit Spielernamen.
- Steuerungs-Auswahl im Menü über `ChoiceChip`:
  - `Touch` (Tippen links/rechts)
  - `Gyro` (Neigungssteuerung über Gerätesensor)

---

## 4. Hauptspiel (game/abschluss_game.dart)

### Erweiterung
- `FlameGame` mit `HasKeyboardHandlerComponents` und `HasCollisionDetection`.

### Wichtige Variablen
- `score`, `baseSpeed`, `currentSpeed`, `playTime` (Sekunden), `enemySpawnTimer`, `enemySpawnInterval`.
- `isGameOver`, `_layoutDone`, `_onLoadDone`, `selectedCarTexture`, `isNewHighscore`.
- `controlMode` – entscheidet, ob `TouchControls` oder `GyroControls` geladen wird.

### onLoad()
1. **Auto-Textur:** `ScoreService.getSelectedCar()` → `selectedCarTexture` (nur gültige Spieler-Autos).
2. **Kamera:**  
   - `camera.viewfinder.visibleGameSize = size`  
   - `camera.viewfinder.position = (size.x/2, size.y/2)` damit (0,0)–(size) den Bildschirm füllt.
3. **World:**  
   - `Road()` → `world.add(road)`  
   - `PlayerCar` (Mitte, 65 % Höhe, 25 % Breite) → `world.add(player)`  
   - `ScoreDisplay` → `camera.viewfinder.add(scoreDisplay)` (HUD, immer vor den Autos)  
   - Je nach Menü-Auswahl:
     - `GyroControls` → `world.add(GyroControls)`  
     - Bei `Touch` wird stattdessen ein Flutter-Overlay mit Pfeil-Buttons eingeblendet
4. **Kollision:** `player.addCollision()`.
5. `_onLoadDone = true`.

### update(dt)
- Wenn `isGameOver`: Abbruch.
- **Spielzeit & Tempo:** `playTime += dt`, `currentSpeed = baseSpeed + (playTime * 8)`, `road.updateSpeed(currentSpeed)`.
- **Gegner-Spawn:**  
  - Timer += dt.  
  - Wenn `enemySpawnTimer >= enemySpawnInterval`: `spawnEnemy()`; bei Erfolg Timer auf 0.  
  - `enemySpawnInterval = (2.0 - playTime*0.035).clamp(0.45, 2.0)` (etwas mehr Gegnerverkehr).
- **Punkte:** `updateScore(dt)`, `scoreDisplay.updateScore(score)`.

### spawnEnemy() → bool
- **Abstand:** Wenn ein Gegner mit `position.y < 40` existiert, wird nicht gespawnt (return false).
- **Spur & Typ:**  
  - `laneIndex = Random().nextInt(4)` (4 Spuren), `enemyTypeIndex = Random().nextInt(3)` (3 Gegnertypen).  
  - Spur und Gegnertyp sind unabhängig zufällig.
- **Position:** Straße mit 12 % Rand, 4 Spuren; Spurmitte berechnet, Spawn-X = Mitte − halbe Autobreite.  
  Spawn-Y: `-carHeight - 80` (oberhalb des Bildschirms).
- **Erzeugen:** `EnemyCar(position, size, texturePath: EnemyCar.carTextures[enemyTypeIndex])`, `enemy.addCollision()`, `world.add(enemy)`, return true.

### updateScore(dt)
- **Speed-Multiplikator:** `(currentSpeed / baseSpeed).clamp(1.0, 5.0)`.
- **Überlebens-Punkte:** intern über einen `double`-Buffer (`_scoreBuffer`) gesammelt, damit der Score schon am Anfang flüssig steigt (ohne Rundungs-Ruckeln).
- **Near-Miss:** Für jeden Gegner ohne `markedForScore`:  
  - Vertikal nah oder gerade vorbeigefahren, horizontal in gleicher Spur (laneWidth * 0.9).  
  - Punkte: 25–50 nach Nähe, mit `speedMultiplier`; werden ebenfalls in den Buffer addiert; dann `enemy.markedForScore = true`.

### gameOver()
- `isGameOver = true`.
- **Zuerst:** `isNewHighscore = await ScoreService.savePlayScore(playerName: playerName, score: score)`.
- Dann `pauseEngine()`, `overlays.add('gameOver')`.

### onGameResize(size)
- `camera.viewfinder.visibleGameSize = size`, `camera.viewfinder.position = (size.x/2, size.y/2)`.
- Einmalig Spieler zentrieren und Größe setzen, wenn `_onLoadDone && !_layoutDone && size > 0`.

### backgroundColor()
- Liefert `Color(0xFF2c3e50)`.

---

## 5. Straße (game/components/road.dart)

### Klasse
- `PositionComponent` mit `HasGameReference<AbschlussGame>`, `priority: -10` (hinten).

### Daten
- `speed`, `roadOffset`; optional `roadSprite`, `textureAspectRatio`; `roadTexturePath = 'road_texture.png'`, `scaleFactor = 1.2`.

### onLoad()
- Lädt `road_texture.png`; bei Erfolg: `roadSprite`, `textureAspectRatio`; sonst Fallback ohne Textur.

### Getter
- **`currentSize`** – `game.size`, Fallback (400, 700) wenn 0.
- **`_scaledTextureHeight`** – aus `currentSize` und Seitenverhältnis, für Textur-Scaling.

### update(dt)
- `size = currentSize`.  
- Mit Textur: `roadOffset += speed * dt`, Wrap.  
- Ohne Textur: `roadOffset -= speed * dt`, Wrap bei 40 (gestrichelte Linien).

### render(canvas)
- Bei Textur: Wiederholtes Zeichnen der Textur mit `roadOffset` (Straße scrollt nach oben).  
- Ohne Textur: Rechteck #4a5568, gelbe Ränder, 3 weiße Linien (4 Spuren).

### updateSpeed(newSpeed)
- Setzt `speed = newSpeed`.

---

## 6. Spieler-Auto (game/components/player_car.dart)

### Klasse
- `SpriteComponent` mit `HasGameReference<AbschlussGame>`, `CollisionCallbacks`, `KeyboardHandler`.

### Daten
- `movingLeft`, `movingRight`, `moveSpeed = 300`, `carTexture`.  
- `_digitalSteerFactor = 0.68` für weichere Touch-/Tastatursteuerung.
- `_tiltAngle`, `_maxTilt = 0.18`, `_tiltSpeed = 8` für Lenk-Animation.

### onLoad()
- `anchor = Anchor.center`.  
- Lädt `carTexture`; bei Fehler: `createPlaceholderSprite(Colors.blue)`.

### addCollision()
- Rechteck-Hitbox 50 % der Größe, zentriert.

### update(dt)
- **Grenzen:** minX/maxX aus 5 % Rand und Autobreite (Position = Mitte).  
- Bewegung links/rechts mit `moveSpeed`, dann `position.x.clamp(minX, maxX)`.  
- **Lenk-Animation:** Ziel-Neigung links/rechts/gerade; `_tiltAngle` interpoliert mit `_tiltSpeed`, `angle = _tiltAngle`.

### onKeyEvent / keysPressed
- Pfeiltasten und A/D setzen `movingLeft` / `movingRight`.

### onCollisionStart
- Wenn `other is EnemyCar` → `game.gameOver()`.

---

## 7. Gegner-Auto (game/components/enemy_car.dart)

### Klasse
- `SpriteComponent` mit `HasGameReference<AbschlussGame>`, `CollisionCallbacks`.

### Daten
- `markedForScore` (für Near-Miss-Punkte nur einmal).  
- `carTextures = ['enemy1.png', 'enemy2.png', 'enemy3.png']`.  
- `texturePath` wird von außen übergeben (Spur und Typ unabhängig zufällig).

### onLoad()
- Lädt `texturePath`; bei Fehler: Platzhalter-Sprite in Rot/Grün/Orange je nach Index.

### addCollision()
- Hitbox 42 % der Größe, um 11 % der Höhe nach unten verschoben (nicht zu weit vorne).

### update(dt)
- `position.y += game.currentSpeed * dt` (alle Gegner gleiche Geschwindigkeit).  
- Wenn `position.y > game.size.y + 100` → `removeFromParent()`.

---

## 8. Score-Anzeige (game/components/score_display.dart)

### Klasse
- `Component` mit `HasGameReference<AbschlussGame>`.

### Daten
- `currentScore`.

### render(canvas)
- Zeichnet „Score: $currentScore“ bei (20, 20), weiß, Schatten.

### updateScore(score)
- Setzt `currentScore = score`.

*(Wird als HUD am Viewfinder hinzugefügt, damit der Score immer vor den Autos liegt.)*

---

## 9. Touch-Steuerung (game/components/control_overlay.dart)

### Widget
- `ControlOverlayWidget` blendet zwei runde Buttons am unteren Bildschirmrand ein:
  - linker Pfeil (`arrow_left`)
  - rechter Pfeil (`arrow_right`)

### Verhalten
- Gedrückt halten auf links: `game.setTouchSteering(left: true, right: false)`
- Gedrückt halten auf rechts: `game.setTouchSteering(left: false, right: true)`
- Loslassen: `game.stopTouchSteering()`
- Bei Game Over ist das Overlay per `IgnorePointer` deaktiviert.

---

## 10. Gyro-Steuerung (game/components/gyro_controls.dart)

### Klasse
- `GyroControls` (`Component` mit `HasGameReference<AbschlussGame>`).

### Verhalten
- Nutzt `sensors_plus` (Accelerometer-Events) für Neigungssteuerung.
- Nutzt für Portrait die `x`-Achse (links/rechts), für Landscape die `y`-Achse.
- Kurze Start-Kalibrierung setzt den aktuellen Haltewinkel als neutralen Mittelpunkt.
- Glättet Sensorwerte und verwendet eine etwas größere Dead-Zone (`0.6`), damit das Auto weniger nervös reagiert.
- Setzt einen analogen Lenkwert (`player.steerInput` von `-1.0` bis `+1.0`) für direkte, stufenlose Steuerung.

---

## 11. Game-Over-Overlay (game/components/game_over_overlay.dart)

### Widget
- `GameOverOverlayWidget(game, finalScore)` – Flutter-StatelessWidget.

### Anzeige
- Halbtransparenter Hintergrund, „Game Over“, bei neuem Highscore „NEUER HIGHSCORE!“, „Score: $finalScore“, Button „Zurück zum Menü“.

### Button
- `game.overlays.remove('gameOver')`, `Navigator.pop(context)`.

---

## 12. Platzhalter-Sprite (game/utils/placeholder_sprite.dart)

### Funktion
- **`createPlaceholderSprite(Color color)`**  
  Zeichnet ein 2×2-Bild in der gewünschten Farbe (PictureRecorder/Canvas), erzeugt daraus ein `ui.Image` und liefert ein Flame-`Sprite`.  
  Wird genutzt, wenn Auto- oder Gegner-Texturen fehlen, damit `SpriteComponent` immer ein gesetztes `sprite` hat.

---

## 13. Score-Service (services/score_service.dart)

Der Score-Service speichert jetzt Highscores und die letzten 3 Spielstände in einer lokalen Hive-"DB".

### Persistenz / Daten
- Hive Box: `_boxName = 'abschluss_score_db'`
- Hive Keys:
  - `_highscoresKey = 'highscores'` (Top-N Highscores, aktuell intern begrenzt)
  - `_lastPlaysKey = 'lastPlays'` (letzte 3 Spielstände)
- Eintragstyp: `ScoreEntry` mit `playerName`, `score`, `playedAt`.

### initDatabase()  
- Ruft `Hive.initFlutter()` auf und öffnet die Box.

### Highscore lesen
- `getTopHighscores({limit})`  
  Liefert die Top-Einträge (Sortierung: `score` absteigend, bei Gleichstand `playedAt` absteigend).
- `getBestScore()`  
  Nutzt `getTopHighscores(...)` und liefert daraus nur die höchste Punktzahl.

### Spiel speichern
- `savePlayScore({playerName, score}) -> Future<bool>`
  - schreibt den neuen Spielstand in:
    - Highscores-Liste (Top-N trimmen)
    - Last-plays-Liste (neueste zuerst, auf 3 kürzen)
  - gibt zurück, ob es insgesamt ein neuer Best-Score war.
  - Auf Web wird zusätzlich auf `await put(...)` und `await box.flush()` gewartet,
    damit der IndexedDB-Schreibvorgang vor einem App-Neustart wirklich abgeschlossen ist.

### Letzte 3 Spiele lesen
- `getLastPlays({limit: 3})`

### Wichtiger Hinweis für Chrome/Web
Auf Web werden die Daten in `IndexedDB` gespeichert. Diese ist an die **Origin** gebunden
(inkl. Port). Wenn du `flutter run -d chrome` öfter startest, kann sich der Port ändern
und damit sind die „alten“ Daten für die neue Origin nicht sichtbar.
Für Tests mit persistierenden Scores empfiehlt sich daher eine feste Portnummer,
z.B. `flutter run -d chrome --web-port 9000`.

### Spielername & Autoauswahl
- Spielername wird (damit er im Menü vorbefüllt ist) mit SharedPreferences gespeichert:
  - `getPlayerName()`, `savePlayerName(...)`
- Autoauswahl bleibt wie vorher in SharedPreferences:
  - `getSelectedCar()`, `saveSelectedCar(...)`
- Steuerungsmodus wird ebenfalls in SharedPreferences gespeichert:
  - `getControlMode()`, `saveControlMode(...)`
  - Werte: `touch` oder `gyro`

---

## 14. Assets (Überblick)

- **Bilder (assets/images/):**  
  - Straße: `road_texture.png`  
  - Spieler: `player_car_1.png`, `player_car_2.png`, `player_car_3.png`  
  - Gegner: `enemy1.png`, `enemy2.png`, `enemy3.png`  
- Fehlende Bilder werden durch Platzhalter-Sprites (einfarbig) ersetzt.

---

## 15. Ablauf zusammengefasst

1. **Start:** `main()` initialisiert Hive (`ScoreService.initDatabase`) → `MenuScreen`.
2. **Name-Eingabe:** `Start` ist deaktiviert, bis ein Spielername eingegeben ist (und wird gespeichert).
3. **Spiel:** `GameScreen` mit `AbschlussGame`; World: Road, Player; Viewfinder: ScoreDisplay. Gegner spawnen zufällig auf 4 Spuren mit 3 Typen, bewegen sich mit `currentSpeed`, Kollision mit Spieler → Game Over.
   - Steuerung im Spiel kommt aus der Menü-Auswahl:
     - `Touch`: Pfeil-Buttons als Overlay (`ControlOverlayWidget`)
     - `Gyro`: Sensorsteuerung (`GyroControls`)
4. **Punkte:** Überlebens-Punkte mit Speed-Multiplikator; Near-Miss-Bonus bei nahem Vorbeifahren.
5. **Game Over:** Spielstand wird als `ScoreEntry` in Hive gespeichert (inkl. Spielernamen). Overlay mit Score und „Zurück zum Menü“.
6. **Zurück:** Navigator.pop → Menü; `_loadData()` lädt Highscores/Letzte 3 sowie Best Score.

Diese Dokumentation deckt alle beschriebenen Funktionen und den Ablauf des Codes ab.
