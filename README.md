# Abschluss - 2D Autorennspiel

Ein 2D-Autorennspiel entwickelt mit Flutter und Flame. Fahren Sie eine Straße entlang und weichen Sie anderen Autos aus, um Punkte zu sammeln!

## 📋 Inhaltsverzeichnis

- [Projektbeschreibung](#projektbeschreibung)
- [Features](#features)
- [Technologie-Stack](#technologie-stack)
- [Installation](#installation)
- [Ausführung](#ausführung)
- [Steuerung](#steuerung)
- [Spielmechanik](#spielmechanik)
- [Projektstruktur](#projektstruktur)
- [Entwickelt mit](#entwickelt-mit)

## 🎮 Projektbeschreibung

"Abschluss" ist ein 2D-Autorennspiel, bei dem der Spieler ein Auto steuert, das eine dreispurige Straße entlangfährt. Das Ziel ist es, so lange wie möglich zu überleben, indem man den entgegenkommenden Autos ausweicht. Je näher man an den Gegner-Autos vorbeifährt, desto mehr Bonus-Punkte erhält man. Mit steigendem Score erhöht sich auch die Geschwindigkeit, was das Spiel zunehmend herausfordernder macht.

## ✨ Features

### Implementierte Funktionen:

1. **Spieler-Auto**
   - Blaues Auto mit gelben Rennstreifen
   - Steuerung nach links und rechts
   - Kollisionserkennung mit Gegner-Autos

2. **Gegner-Autos**
   - Verschiedene farbige Autos (Rot, Grün, Orange, Lila)
   - Spawnen zufällig in drei Spuren
   - Bewegen sich mit steigender Geschwindigkeit nach unten

3. **Straßen-System**
   - Dreispurige Straße
   - Gelbe Randlinien
   - Weiße gestrichelte Mittellinien
   - Animierte Straßenmarkierungen

4. **Score-System**
   - Basis-Punkte für überlebte Zeit
   - Bonus-Punkte basierend auf Nähe zu Gegner-Autos
   - Score-Anzeige in der oberen linken Ecke

5. **Geschwindigkeitssteigerung**
   - Geschwindigkeit erhöht sich mit dem Score
   - Gegner-Autos spawnen häufiger bei höherem Score
   - Dynamische Schwierigkeitsanpassung

6. **Kollisionserkennung**
   - Spiel endet bei Kollision mit Gegner-Auto
   - Präzise Hitbox-Erkennung

7. **Steuerung**
   - Tastatur-Steuerung (Pfeiltasten oder A/D)
   - Touch-Steuerung für mobile Geräte

## 🛠 Technologie-Stack

- **Flutter** - UI-Framework
- **Flame** (v1.20.0) - 2D-Spiel-Engine
- **Dart** (SDK ^3.9.2) - Programmiersprache

## 📦 Installation

### Voraussetzungen

- Flutter SDK (Version 3.9.2 oder höher)
- Dart SDK
- Ein Emulator oder physisches Gerät zum Testen

### Abhängigkeiten installieren

1. Navigieren Sie zum Projektverzeichnis:
```bash
cd /home/batuhan/uni/flutter/projects/abschluss
```

2. Installieren Sie die Abhängigkeiten:
```bash
flutter pub get
```

## 🚀 Ausführung

### Spiel starten

```bash
cd /home/batuhan/uni/flutter/projects/abschluss
flutter run
```

### Verfügbare Geräte anzeigen

```bash
flutter devices
```

### Für ein spezifisches Gerät starten

```bash
flutter run -d <device-id>
```

### Code analysieren

```bash
flutter analyze
```

## 🎯 Steuerung

### Tastatur (Desktop/Web)

- **Pfeiltaste Links** oder **A** - Auto nach links bewegen
- **Pfeiltaste Rechts** oder **D** - Auto nach rechts bewegen

### Touch (Mobile)

- **Linke Bildschirmhälfte tippen** - Auto nach links bewegen
- **Rechte Bildschirmhälfte tippen** - Auto nach rechts bewegen

## 🎲 Spielmechanik

### Spielziel

Überleben Sie so lange wie möglich und sammeln Sie dabei so viele Punkte wie möglich.

### Punktesystem

1. **Basis-Punkte**: 
   - Kontinuierliche Punkte für überlebte Zeit
   - Rate: ~10 Punkte pro Sekunde

2. **Bonus-Punkte**:
   - Erhalten Sie zusätzliche Punkte, wenn Sie nah an Gegner-Autos vorbeifahren
   - Formel: `Bonus = (100 - Distanz) / 5`
   - Je näher, desto mehr Punkte!

### Geschwindigkeitssteigerung

- **Basis-Geschwindigkeit**: 100 Pixel/Sekunde
- **Geschwindigkeitsformel**: `Aktuelle Geschwindigkeit = Basis + (Score × 0.1)`
- Mit steigendem Score wird das Spiel schneller und herausfordernder

### Spawn-System

- Gegner-Autos spawnen in zufälligen Spuren
- **Anfängliches Spawn-Intervall**: 2 Sekunden
- **Dynamisches Intervall**: Verkürzt sich mit steigendem Score
- **Minimum**: 0.5 Sekunden zwischen Spawns

### Kollisionserkennung

- Rechteckige Hitboxen für präzise Kollisionserkennung
- Spiel endet sofort bei Kollision
- Gegner-Autos werden automatisch entfernt, wenn sie den Bildschirm verlassen

## 📁 Projektstruktur

```
abschluss/
├── lib/
│   ├── main.dart                 # Haupt-Einstiegspunkt der App
│   └── game/
│       ├── abschluss_game.dart   # Hauptspiel-Klasse (FlameGame)
│       └── components/
│           ├── player_car.dart    # Spieler-Auto Komponente
│           ├── enemy_car.dart    # Gegner-Auto Komponente
│           ├── road.dart         # Straßen-System Komponente
│           ├── score_display.dart # Score-Anzeige Komponente
│           └── touch_controls.dart # Touch-Steuerung Komponente
├── pubspec.yaml                  # Projekt-Konfiguration und Abhängigkeiten
└── README.md                     # Diese Datei
```

### Dateibeschreibungen

#### `main.dart`
- Initialisiert die Flutter-App
- Erstellt den GameScreen mit dem Flame GameWidget

#### `abschluss_game.dart`
- Hauptspiel-Logik
- Verwaltet Score, Geschwindigkeit, Spawn-Timer
- Koordiniert alle Spielkomponenten
- Implementiert Kollisionserkennung

#### `player_car.dart`
- Spieler-Auto Komponente
- Handhabt Tastatur-Eingaben
- Bewegungslogik (links/rechts)
- Kollisionsbehandlung

#### `enemy_car.dart`
- Gegner-Auto Komponente
- Verschiedene Farben für Abwechslung
- Automatische Bewegung nach unten
- Auto-Entfernung bei Bildschirmausgang

#### `road.dart`
- Straßen-Rendering
- Animierte Straßenmarkierungen
- Drei Spuren mit gelben Randlinien

#### `score_display.dart`
- Score-Anzeige im UI
- Aktualisiert sich kontinuierlich

#### `touch_controls.dart`
- Touch-Eingabe-Handling
- Links/Rechts-Steuerung basierend auf Tipp-Position

## 🔧 Entwickelt mit

- **Flutter** - https://flutter.dev
- **Flame** - https://flame-engine.org
- **Dart** - https://dart.dev

## 📝 Hinweise

### Texturen hinzufügen

Das Spiel verwendet aktuell einfache farbige Rechtecke für die Autos. Um Texturen hinzuzufügen:

1. Erstellen Sie einen `assets/images/` Ordner
2. Fügen Sie Ihre Auto-Bilder hinzu (z.B. `player_car.png`, `enemy_car.png`)
3. Aktualisieren Sie `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
```
4. Passen Sie die Komponenten an, um `SpriteComponent` statt `RectangleComponent` zu verwenden

### Erweiterungsmöglichkeiten

- Game-Over-Screen mit Restart-Funktion
- Highscore-Speicherung
- Verschiedene Schwierigkeitsgrade
- Power-Ups
- Sound-Effekte und Musik
- Auto-Auswahl vor Spielstart
- Mehrspieler-Modus

## 📄 Lizenz

Dieses Projekt wurde für Bildungszwecke erstellt.

---

**Viel Spaß beim Spielen! 🏎️💨**
