import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../abschluss_game.dart';

class TouchControls extends Component
    with HasGameReference<AbschlussGame>, TapCallbacks {
  @override
  bool onTapDown(TapDownEvent event) {
    final player = game.player;
    final tapX = event.localPosition.x;
    final screenWidth = game.size.x;
    
    // Linke Hälfte = links, rechte Hälfte = rechts
    if (tapX < screenWidth / 2) {
      player.movingLeft = true;
      player.movingRight = false;
    } else {
      player.movingRight = true;
      player.movingLeft = false;
    }
    
    return true;
  }
  
  @override
  bool onTapUp(TapUpEvent event) {
    final player = game.player;
    player.movingLeft = false;
    player.movingRight = false;
    return true;
  }
  
  @override
  bool onTapCancel(TapCancelEvent event) {
    final player = game.player;
    player.movingLeft = false;
    player.movingRight = false;
    return true;
  }
}

