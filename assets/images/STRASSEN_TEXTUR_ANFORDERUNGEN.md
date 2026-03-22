# Anforderungen für Straßen-Textur

## 📐 Technische Anforderungen

### Dateiformat
- **Format:** PNG (mit oder ohne Transparenz)
- **Alternativ:** JPG (wenn kein transparenter Hintergrund benötigt wird)

### Größe
- **Breite:** 200-400 Pixel (empfohlen: 300 Pixel)
- **Höhe:** Kann variieren, sollte aber nahtlos wiederholbar sein
- **Seitenverhältnis:** Die Textur sollte sich vertikal nahtlos wiederholen lassen

### Design-Anforderungen

#### 1. Perspektive
- **Top-Down-Ansicht** (von oben gesehen)
- Die Straße sollte so aussehen, als würde man von oben darauf schauen

#### 2. Spuren
- **3 Fahrspuren** sollten sichtbar sein
- Spuren sollten gleichmäßig verteilt sein
- Spuren sollten klar voneinander getrennt sein

#### 3. Straßenmarkierungen
- **Mittellinien:** Weiße gestrichelte Linien zwischen den Spuren
- **Randlinien:** Gelbe oder weiße Linien an den Seiten (optional)
- Die Markierungen sollten sich nahtlos wiederholen lassen

#### 4. Wiederholbarkeit (Tileable)
- **Wichtig:** Die Textur muss sich **nahtlos wiederholen** lassen
- Das bedeutet: Der obere Rand muss nahtlos mit dem unteren Rand verbunden werden können
- Keine sichtbaren Nahtstellen beim Wiederholen

#### 5. Farben
- **Straßenbelag:** Dunkelgrau bis schwarz (z.B. Asphalt)
- **Markierungen:** Weiß für Mittellinien
- **Optional:** Gelb für Randlinien
- **Hintergrund:** Kann transparent sein oder die Straßenfarbe haben

## 🎨 Design-Vorschläge

### Option 1: Einfache Asphalt-Textur
- Dunkelgrauer/schwarzer Asphalt
- 3 Spuren mit weißen gestrichelten Mittellinien
- Einfach und klar

### Option 2: Detaillierte Straße
- Realistische Asphalt-Textur mit Texturdetails
- 3 Spuren mit weißen gestrichelten Linien
- Gelbe Randlinien
- Eventuell Schatten für Tiefe

### Option 3: Minimalistisch
- Sehr einfaches Design
- Klare Linien
- Wenig Details

## 📝 Dateiname

**Empfohlener Dateiname:** `road_texture.png`

Die Datei sollte in den Ordner `assets/images/` gelegt werden.

## 🔄 Nach dem Hinzufügen

Nachdem Sie die Textur hinzugefügt haben:

1. Die Datei muss in `assets/images/` liegen
2. Die Textur wird automatisch geladen (falls der Code angepasst wird)
3. Die Textur wird vertikal wiederholt, um eine endlose Straße zu simulieren

## 💡 Tipps

- **Tileable erstellen:** Verwenden Sie Tools wie GIMP oder Photoshop mit "Offset"-Filter, um sicherzustellen, dass die Textur nahtlos wiederholbar ist
- **Größe testen:** Testen Sie die Textur in verschiedenen Größen, um sicherzustellen, dass sie gut aussieht
- **Konsistenz:** Die Textur sollte zum Stil der Auto-Texturen passen (realistisch, cartoonig, minimalistisch, etc.)

## 📦 Beispiel-Größen

- **Klein:** 200x100 Pixel (für einfache Texturen)
- **Mittel:** 300x150 Pixel (empfohlen)
- **Groß:** 400x200 Pixel (für detaillierte Texturen)

**Wichtig:** Die Höhe kann variieren, sollte aber so gewählt werden, dass die Wiederholung nahtlos ist.

---

**Viel Erfolg beim Erstellen der Straßen-Textur! 🛣️**

