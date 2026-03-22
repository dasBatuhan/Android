import 'dart:async';

import 'package:flame/components.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../abschluss_game.dart';

/// Lenkt das Auto mit Gerätesensoren.
///
/// Für eine gut spielbare Neigungssteuerung nutzen wir die X-Achse des
/// Accelerometers (links/rechts kippen).
class GyroControls extends Component with HasGameReference<AbschlussGame> {
  static const double _deadZone = 0.6;
  static const double _maxAbsolute = 7.5;

  StreamSubscription<AccelerometerEvent>? _sub;
  double _smoothedTilt = 0.0;
  double _baseline = 0.0;
  int _baselineSamples = 0;
  static const int _baselineSampleCount = 24;

  @override
  Future<void> onLoad() async {
    _sub = accelerometerEventStream().listen((event) {
      // Für dieses Spiel ist die natürliche Haltung Portrait.
      // Links/Rechts-Neigung kommt dort zuverlässig über die X-Achse.
      // Falls das Spiel im Landscape läuft, nehmen wir stattdessen Y.
      final isPortrait = game.size.y >= game.size.x;
      final rawTilt = isPortrait ? -event.x : event.y;

      // Kurze Start-Kalibrierung: aktueller Haltewinkel wird als "neutral" gesetzt.
      if (_baselineSamples < _baselineSampleCount) {
        _baseline = (_baseline * _baselineSamples + rawTilt) / (_baselineSamples + 1);
        _baselineSamples++;
      }

      final centered = rawTilt - _baseline;

      // Leichte Glättung gegen Sensor-Rauschen
      _smoothedTilt = (_smoothedTilt * 0.72) + (centered * 0.28);

      final tilt = _smoothedTilt.clamp(-_maxAbsolute, _maxAbsolute);
      final player = game.player;

      // Analoge Lenkung direkt setzen (-1..+1)
      if (tilt.abs() < _deadZone) {
        player.steerInput = 0.0;
      } else {
        player.steerInput = (tilt / _maxAbsolute).clamp(-1.0, 1.0);
      }
      // Digitale Flags deaktivieren, damit nichts gegeneinander arbeitet
      player.movingLeft = false;
      player.movingRight = false;
    });
  }

  @override
  void onRemove() {
    if (game.isMounted) {
      game.player.steerInput = 0.0;
    }
    _sub?.cancel();
    _sub = null;
    super.onRemove();
  }
}
