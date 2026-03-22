# Abschluss – 2D-Autorennspiel

Ein 2D-Top-Down-Rennspiel mit **Flutter** und **Flame**: Straße entlangfahren, Gegner ausweichen und Punkte sammeln.

## Inhaltsverzeichnis

- [Projektbeschreibung](#projektbeschreibung)
- [Features](#features)
- [Technologie-Stack](#technologie-stack)
- [Installation](#installation)
- [Ausführung](#ausführung)
- [Steuerung](#steuerung)
- [Spielmechanik](#spielmechanik)
- [Projektstruktur](#projektstruktur)
- [Scores & Persistenz](#scores--persistenz)
- [Weitere Dokumentation](#weitere-dokumentation) (inkl. `UMSETZUNG.md`)
- [Hinweise](#hinweise)
- [Lizenz](#lizenz)

## Projektbeschreibung

**Abschluss** ist ein 2D-Rennspiel, bei dem du ein Auto auf einer mehrspurigen Straße steuerst. Ziel ist, möglichst lange zu überleben und den **Score** zu erhöhen. Nahe Vorbeifahrten an Gegnern geben **Bonuspunkte**; mit steigendem Score werden **Geschwindigkeit** und **Spawn-Rate** der Gegner anspruchsvoller.

## Features

1. **Startmenü** – Spielername (Pflicht), Auswahl des Spieler-Autos, **Touch-** oder **Gyro-Steuerung**
2. **Spieler-Auto** – mehrere Skins (`assets/images/`), Kollision beendet das Spiel
3. **Gegner-Autos** – verschiedene Typen, zufällige Spur, Fahrt nach unten
4. **Straße** – mehrere Spuren, Markierungen und Fahrbahn-Optik
5. **Score** – Zeit-/Überlebenspunkte + Nähe-Bonus; Anzeige im Spiel
6. **Highscores & Verlauf** – Top-Liste und letzte Spiele lokal mit **Hive**; Name/Auto/Steuerung mit **SharedPreferences**
7. **Game-Over-Overlay** – Ergebnis, Hinweis bei neuem persönlichen Highscore, Rückkehr ins Menü
8. **Robustheit** – fehlende Bilder werden durch **Platzhalter-Sprites** ersetzt (`placeholder_sprite.dart`)

## Technologie-Stack

| Technologie | Verwendung |
|-------------|------------|
| **Flutter** | UI, Navigation, Overlays |
| **Flame** (^1.20) | 2D-Spiel-Engine, Komponenten, Kollisionen |
| **Dart** (^3.9) | Sprache |
| **Hive** + **hive_flutter** | Lokale Highscores & letzte Spiele |
| **shared_preferences** | Spielername, Autowahl, Steuerungsmodus |
| **sensors_plus** | Gyro-/Lagesensor-Steuerung |

## Installation

### Voraussetzungen

- Flutter SDK (passend zu `environment.sdk` in `pubspec.yaml`)
- Emulator, Browser oder physisches Gerät

### Abhängigkeiten

```bash
cd projects/abschluss   # oder dein Pfad zum Projekt
flutter pub get
```

## Ausführung

```bash
flutter run
```

Gerät wählen:

```bash
flutter devices
flutter run -d <device-id>
```

**Web (Chrome)** – für stabile lokale Speicherung oft fester Port:

```bash
flutter run -d chrome --web-port 9000
```

*(Hive/Web nutzt IndexedDB pro Origin – wechselnder Port = „leere“ Datenbank.)*

Analyse:

```bash
flutter analyze
```

## Steuerung

### Tastatur (Desktop / Web)

- **←** / **A** – links  
- **→** / **D** – rechts  

### Touch (Menü-Modus „Touch“)

- **Pfeil-Buttons** unten im Bildschirm (`ControlOverlayWidget`)

### Gyro (Menü-Modus „Gyro“)

- **Handy neigen** – seitliche Steuerung (sinnvoll auf echtem Gerät mit Sensor)

## Spielmechanik

- **Ziel:** Überleben und Score maximieren  
- **Basis-Punkte** für überlebte Zeit  
- **Bonus** bei geringem Abstand zu Gegnern (Near-Miss)  
- **Geschwindigkeit** und **Spawn-Intervall** skalieren mit dem Score  
- **Kollision** mit Gegner → Game Over  

(Detailzahlen und Formeln siehe `DOKUMENTATION.md`.)

## Projektstruktur

```
abschluss/
├── lib/
│   ├── main.dart                    # App-Start, GameScreen, Overlays
│   ├── screens/
│   │   └── menu_screen.dart         # Startmenü
│   ├── services/
│   │   └── score_service.dart       # Hive + SharedPreferences
│   ├── game/
│   │   ├── abschluss_game.dart      # FlameGame, Logik, Spawns
│   │   ├── utils/
│   │   │   └── placeholder_sprite.dart
│   │   └── components/
│   │       ├── road.dart
│   │       ├── player_car.dart
│   │       ├── enemy_car.dart
│   │       ├── score_display.dart
│   │       ├── control_overlay.dart
│   │       ├── gyro_controls.dart
│   │       ├── game_over_overlay.dart
│   │       └── touch_controls.dart
│   └── …
├── assets/images/                   # Straße, Spieler-, Gegner-Grafiken
├── pubspec.yaml
├── README.md                        # Diese Datei
├── DOKUMENTATION.md                 # Technische Projektdoku
└── PRAESENTATION_FOLIEN.md          # Folienentwurf für Vortrag
```

### Kurz zu den Hauptdateien

| Datei | Rolle |
|-------|--------|
| `main.dart` | `ScoreService.initDatabase()`, `MenuScreen`, `GameWidget` + Overlays |
| `menu_screen.dart` | Name, Auto, Steuerung, Anzeige Bestenliste / letzte Spiele |
| `abschluss_game.dart` | Score, Speed, Gegner-Spawns (u. a. 4 Spuren), Game Over |
| `score_service.dart` | `ScoreEntry`, Hive-Box `abschluss_score_db`, Einstellungen |

## Scores & Persistenz

- **Highscores** (nur die **3 besten**) und **letzte Spiele** (3 Stück) liegen in einer **Hive**-Box (`abschluss_score_db`), Keys u. a. `highscores`, `lastPlays`.
- **Web:** Speicherung im **IndexedDB** der aktuellen Origin (Host + Port).
- **Android/iOS/Desktop:** interne App-Daten – kein einzelner Projektordner im Repo.

## Weitere Dokumentation

- **`DOKUMENTATION.md`** – durchgängige Beschreibung von Ablauf, Modulen und Score-Service.  
- **`UMSETZUNG.md`** – **Architektur-Diagramme** (Schichten, Sequenzen, Komponenten, Persistenz).  
- **`PROJEKT_EINFACH_ERKLAERT.md`** – kurze Erklärung für Einsteiger: Ablauf, Dateien, Zusammenspiel.  
- **`PRAESENTATION_FOLIEN.md`** – vorgeschlagene Folien für Präsentationen.

## Hinweise

### Assets

Grafiken liegen unter `assets/images/` und sind in `pubspec.yaml` unter `flutter: assets` eingetragen. Fehlende Dateien führen nicht zum Absturz dank Platzhalter-Sprites.

### Mögliche Erweiterungen

- Sound / Musik  
- Schwierigkeitsgrade oder Power-Ups  
- Online-Rangliste (z. B. Backend mit Regeln gegen Missbrauch)  
- Mehr Strecken oder Gegner-Verhalten  

## Lizenz

Projekt zu Bildungszwecken.

---

**Viel Spaß beim Spielen.**
