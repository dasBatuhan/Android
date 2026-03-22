import 'package:flutter/material.dart';
import '../main.dart';
import '../services/score_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int bestScore = 0;
  String selectedCar = 'player_car_1.png';
  String? _hoveredCar;
  String _playerName = '';
  String _controlMode = ScoreService.controlModeTouch;

  final TextEditingController _nameController = TextEditingController();
  List<ScoreEntry> _topHighscores = const [];
  List<ScoreEntry> _lastPlays = const [];

  // Spielbare Autos (player_car_1–3)
  final List<CarOption> availableCars = [
    CarOption(texture: 'player_car_1.png', color: Colors.blue),
    CarOption(texture: 'player_car_2.png', color: Colors.grey),
    CarOption(texture: 'player_car_3.png', color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final score = await ScoreService.getBestScore();
    final car = await ScoreService.getSelectedCar();
    final name = await ScoreService.getPlayerName();
    final controlMode = await ScoreService.getControlMode();
    final top = await ScoreService.getTopHighscores(limit: 3);
    final last = await ScoreService.getLastPlays(limit: 3);
    setState(() {
      bestScore = score;
      selectedCar = car;
      _playerName = name;
      _controlMode = controlMode;
      _nameController.text = name;
      _topHighscores = top;
      _lastPlays = last;
    });
  }

  Future<void> _selectCar(String texture) async {
    await ScoreService.saveSelectedCar(texture);
    setState(() {
      selectedCar = texture;
    });
  }

  Future<void> _startGame() async {
    final trimmedName = _playerName.trim();
    if (trimmedName.isEmpty) return;
    await ScoreService.savePlayerName(trimmedName);
    await ScoreService.saveControlMode(_controlMode);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerName: trimmedName,
          controlMode: _controlMode,
        ),
      ),
    ).then((_) {
      // Nach dem Spiel zurück zum Menü, Best Score aktualisieren
      _loadData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/road_texture.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54,
                Colors.black87,
                Colors.black87,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spielername (Pflicht)
                  const Text(
                    'Dein Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: _nameController,
                      onChanged: (value) => setState(() => _playerName = value),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black26,
                        hintText: 'z.B. Ali',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titel
                  const Text(
                    'Racing Game',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Best Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Best Score',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$bestScore',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Top Highscores (mit Namen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Highscores (Top 3)',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_topHighscores.isEmpty)
                          const Text(
                            'Noch keine Spiele gespeichert.',
                            style: TextStyle(color: Colors.white54),
                          )
                        else
                          ..._topHighscores.asMap().entries.map((e) {
                            final idx = e.key + 1;
                            final item = e.value;
                            return Text(
                              '$idx. ${item.playerName} – ${item.score}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Letzte 3 Spiele (mit Namen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Letzte 3 Spiele',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_lastPlays.isEmpty)
                          const Text(
                            'Noch keine Spielstände vorhanden.',
                            style: TextStyle(color: Colors.white54),
                          )
                        else
                          ..._lastPlays.asMap().entries.map((e) {
                            final idx = e.key + 1;
                            final item = e.value;
                            return Text(
                              '$idx. ${item.playerName} – ${item.score}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Steuerungs-Auswahl
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Steuerung',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ChoiceChip(
                              label: const Text('Touch'),
                              selected: _controlMode == ScoreService.controlModeTouch,
                              onSelected: (_) {
                                setState(() {
                                  _controlMode = ScoreService.controlModeTouch;
                                });
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Gyro'),
                              selected: _controlMode == ScoreService.controlModeGyro,
                              onSelected: (_) {
                                setState(() {
                                  _controlMode = ScoreService.controlModeGyro;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Auto-Auswahl
                  const Text(
                    'Auto auswählen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: availableCars.map((car) {
                      final isSelected = selectedCar == car.texture;
                      final isHovered = _hoveredCar == car.texture;
                      final scale = isSelected ? 1.35 : (isHovered ? 1.08 : 1.0);
                      return MouseRegion(
                        onEnter: (_) => setState(() => _hoveredCar = car.texture),
                        onExit: (_) => setState(() => _hoveredCar = null),
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _selectCar(car.texture),
                          child: AnimatedScale(
                            scale: scale,
                            duration: const Duration(milliseconds: 150),
                            child: SizedBox(
                              width: 130,
                              height: 130,
                              child: Image.asset(
                                'assets/images/${car.texture}',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  color: car.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  
                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _playerName.trim().isEmpty ? null : _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class CarOption {
  final String texture;
  final Color color;

  CarOption({required this.texture, required this.color});
}

