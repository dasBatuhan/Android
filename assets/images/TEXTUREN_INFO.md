# Benötigte Texturen für das Abschluss-Spiel

## 📁 Ordnerstruktur

Alle Texturen sollten in diesem Ordner (`assets/images/`) platziert werden.

## 🎨 Benötigte Texturen

### 1. Spieler-Auto
**Dateiname:** `player_car.png` (oder `.jpg`)

**Beschreibung:**
- Auto von oben gesehen (Top-Down-Ansicht)
- Blaues Auto mit gelben Rennstreifen (optional)
- Größe: Empfohlen 50x80 Pixel oder größer (2:1 Seitenverhältnis)
- Transparenter Hintergrund (PNG mit Alpha-Kanal)
- Auto sollte nach oben zeigen (in Fahrtrichtung)

**Beispiel:**
- Einfaches Auto-Design von oben
- Kann ein Rennwagen, Sportwagen oder normales Auto sein
- Farbe: Blau mit gelben Akzenten (passt zum aktuellen Design)

---

### 2. Gegner-Autos (4 verschiedene Varianten)
**Dateinamen:** 
- `enemy_car_red.png`
- `enemy_car_green.png`
- `enemy_car_orange.png`
- `enemy_car_purple.png`

**Beschreibung:**
- Autos von oben gesehen (Top-Down-Ansicht)
- Verschiedene Farben für Abwechslung
- Größe: Empfohlen 50x80 Pixel oder größer (2:1 Seitenverhältnis)
- Transparenter Hintergrund (PNG mit Alpha-Kanal)
- Auto sollte nach unten zeigen (entgegenkommend)

**Farben:**
- **Rot** (`enemy_car_red.png`) - Rotes Auto
- **Grün** (`enemy_car_green.png`) - Grünes Auto
- **Orange** (`enemy_car_orange.png`) - Oranges Auto
- **Lila** (`enemy_car_purple.png`) - Lila Auto

**Alternative:** Falls Sie nur eine Textur haben, kann ich den Code so anpassen, dass die Farbe programmatisch geändert wird.

---

## 📐 Technische Anforderungen

### Dateiformat
- **Empfohlen:** PNG (mit transparentem Hintergrund)
- **Alternativ:** JPG (wenn kein transparenter Hintergrund benötigt wird)

### Größe
- **Minimale Größe:** 50x80 Pixel
- **Empfohlen:** 100x160 Pixel oder höher (für bessere Qualität)
- **Seitenverhältnis:** Etwa 2:1 (Höhe:Breite)
- **Maximale Größe:** 200x320 Pixel (um Performance zu gewährleisten)

### Design-Richtlinien
- **Perspektive:** Top-Down (von oben gesehen)
- **Hintergrund:** Transparent (PNG) oder einfarbig
- **Stil:** Kann realistisch, cartoonig oder minimalistisch sein
- **Ausrichtung:** 
  - Spieler-Auto: Nach oben zeigend
  - Gegner-Autos: Nach unten zeigend

---

## 🎯 Optionale Texturen (für zukünftige Erweiterungen)

### Straßen-Texturen
- `road_asphalt.png` - Asphalt-Textur für die Straße
- `road_line.png` - Straßenmarkierung (wiederholbar)

### UI-Elemente
- `button_left.png` - Linker Steuerungsbutton
- `button_right.png` - Rechter Steuerungsbutton
- `game_over.png` - Game-Over-Bildschirm

### Effekte
- `explosion.png` - Explosions-Animation (bei Kollision)
- `particle.png` - Partikel-Effekte

---

## 📝 Hinweise

1. **Einheitliche Größe:** Alle Auto-Texturen sollten die gleiche Größe haben
2. **Konsistenter Stil:** Alle Texturen sollten im gleichen Stil sein
3. **Performance:** Kleinere Dateigrößen = bessere Performance
4. **Transparenz:** PNG mit Alpha-Kanal ermöglicht bessere Integration

---

## 🔄 Nach dem Hinzufügen der Texturen

Nachdem Sie die Texturen hinzugefügt haben:

1. Führen Sie `flutter pub get` aus
2. Informieren Sie mich, damit ich den Code anpasse, um die Texturen zu verwenden
3. Das Spiel wird dann automatisch die Texturen statt der farbigen Rechtecke verwenden

---

## 💡 Tipps zum Erstellen der Texturen

- Verwenden Sie kostenlose Ressourcen wie:
  - [OpenGameArt.org](https://opengameart.org)
  - [Kenney.nl](https://kenney.nl/assets)
  - [itch.io - Free Assets](https://itch.io/game-assets/free)
- Oder erstellen Sie eigene mit Tools wie:
  - GIMP (kostenlos)
  - Photoshop
  - Aseprite (für Pixel-Art)
  - Inkscape (für Vektorgrafiken)

---

**Viel Erfolg beim Sammeln der Texturen! 🎨**

