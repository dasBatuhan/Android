import 'package:flutter/material.dart';

import '../abschluss_game.dart';

class ControlOverlayWidget extends StatelessWidget {
  final AbschlussGame game;

  const ControlOverlayWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final leftButton = _ArrowControlButton(
      icon: Icons.arrow_left_rounded,
      onDown: () => game.setTouchSteering(left: true, right: false),
      onUp: game.stopTouchSteering,
    );
    final rightButton = _ArrowControlButton(
      icon: Icons.arrow_right_rounded,
      onDown: () => game.setTouchSteering(left: false, right: true),
      onUp: game.stopTouchSteering,
    );

    return IgnorePointer(
      ignoring: game.isGameOver,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                leftButton,
                rightButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _ArrowControlButton({
    required this.icon,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_ArrowControlButton> createState() => _ArrowControlButtonState();
}

class _ArrowControlButtonState extends State<_ArrowControlButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
    if (pressed) {
      widget.onDown();
    } else {
      widget.onUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: _pressed ? Colors.green.shade700 : Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Icon(
          widget.icon,
          size: 54,
          color: Colors.white,
        ),
      ),
    );
  }
}
