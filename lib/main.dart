import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/abschluss_game.dart';
import 'game/components/control_overlay.dart';
import 'game/components/game_over_overlay.dart';
import 'screens/menu_screen.dart';
import 'services/score_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScoreService.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abschluss Spiel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String playerName;
  final String controlMode;

  const GameScreen({
    super.key,
    required this.playerName,
    required this.controlMode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AbschlussGame game;

  @override
  void initState() {
    super.initState();
    game = AbschlussGame(
      playerName: widget.playerName,
      controlMode: widget.controlMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<AbschlussGame>.controlled(
        gameFactory: () => game,
        initialActiveOverlays: widget.controlMode == ScoreService.controlModeTouch
            ? const ['controls']
            : const [],
        overlayBuilderMap: {
          'controls': (BuildContext context, AbschlussGame game) {
            return ControlOverlayWidget(game: game);
          },
          'gameOver': (BuildContext context, AbschlussGame game) {
            return GameOverOverlayWidget(
              game: game,
              finalScore: game.score,
            );
          },
        },
      ),
    );
  }
}
