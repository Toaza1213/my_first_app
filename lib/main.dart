import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ExpLabApp());
}

class ExpLabApp extends StatelessWidget {
  const ExpLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EXP-LAB: 3D Raycaster & Neural Reader & Audio Scope',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainLabScreen(),
    );
  }
}

class MainLabScreen extends StatefulWidget {
  const MainLabScreen({super.key});

  @override
  State<MainLabScreen> createState() => _MainLabScreenState();
}

class _MainLabScreenState extends State<MainLabScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Raycaster3DScreen(),
    BionicSpeedReaderScreen(),
    AudioOscilloscopeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFF10B981).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset, color: Color(0xFF10B981)),
            label: '🎮 3D Raycasting Maze',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt, color: Color(0xFF00F0FF)),
            label: '🧠 Bionic Speed Reader',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq_outlined),
            selectedIcon: Icon(Icons.graphic_eq, color: Color(0xFFFF007A)),
            label: '🌊 Audio Oscilloscope',
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 1. MODULE 1: RETRO 3D RAYCASTING MAZE (DOOM / WOLFENSTEIN 3D ENGINE)
// =========================================================================
class Raycaster3DScreen extends StatefulWidget {
  const Raycaster3DScreen({super.key});

  @override
  State<Raycaster3DScreen> createState() => _Raycaster3DScreenState();
}

class _Raycaster3DScreenState extends State<Raycaster3DScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gameLoop;
  final FocusNode _focusNode = FocusNode();

  // แผนที่เขาวงกต (0: ที่ว่าง, 1: กำแพงสีฟ้า, 2: กำแพงสีเขียว, 3: กำแพงสีม่วง)
  final List<List<int>> map = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
    [1, 0, 2, 2, 0, 0, 1, 0, 3, 3, 0, 1],
    [1, 0, 2, 0, 0, 0, 0, 0, 0, 3, 0, 1],
    [1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1],
    [1, 0, 0, 3, 0, 0, 0, 2, 2, 2, 0, 1],
    [1, 0, 0, 3, 0, 1, 0, 0, 0, 0, 0, 1],
    [1, 0, 3, 3, 0, 1, 0, 0, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ];

  // ตำแหน่งผู้เล่นเริ่มต้น (อยู่ที่โถงทางเดินโล่ง Row 1, Col 1) และทิศทางมุมมอง
  double posX = 1.5;
  double posY = 1.5;
  double dirX = 0.0;
  double dirY = 1.0;
  double planeX = 0.66;
  double planeY = 0.0; // FOV 66 องศา

  @override
  void initState() {
    super.initState();
    _gameLoop = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _movePlayer(double forward, double turn) {
    setState(() {
      // 1. หมุนมุมมองกล้อง (เลี้ยวซ้าย / เลี้ยวขวา)
      if (turn != 0) {
        final rot = turn * 0.1;
        final oldDirX = dirX;
        dirX = dirX * cos(rot) - dirY * sin(rot);
        dirY = oldDirX * sin(rot) + dirY * cos(rot);

        final oldPlaneX = planeX;
        planeX = planeX * cos(rot) - planeY * sin(rot);
        planeY = oldPlaneX * sin(rot) + planeY * cos(rot);
      }

      // 2. เดินหน้า / ถอยหลัง พร้อมตรวจจับการชนกำแพง
      if (forward != 0) {
        final moveSpeed = forward * 0.15;
        final newX = (posX + dirX * moveSpeed).clamp(1.1, 10.9);
        final newY = (posY + dirY * moveSpeed).clamp(1.1, 10.9);

        // เช็คการชนกำแพงทีละแกน เพื่อให้สไลด์ไปตามผนังได้
        if (map[newX.toInt()][posY.toInt()] == 0) {
          posX = newX;
        }
        if (map[posX.toInt()][newY.toInt()] == 0) {
          posY = newY;
        }
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _movePlayer(1, 0);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS || event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _movePlayer(-1, 0);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _movePlayer(0, -1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _movePlayer(0, 1);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Flexible(
                child: Text('3D RAYCASTING MAZE',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ],
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Text('CONTROLS: W, A, S, D / ปุ่มทิศทาง',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Stack(
          children: [
            // หน้าจอเรนเดอร์ 3 มิติจากคณิตศาสตร์ Raycasting
            Positioned.fill(
              child: CustomPaint(
                painter: RaycasterPainter(
                  posX: posX,
                  posY: posY,
                  dirX: dirX,
                  dirY: dirY,
                  planeX: planeX,
                  planeY: planeY,
                  map: map,
                ),
              ),
            ),

            // เป้าเล็ง Crosshair กึ่งกลางจอ
            const Center(
              child: Icon(Icons.add, color: Colors.white38, size: 28),
            ),

            // Mini-map เรดาร์มุมขวาบน
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: CustomPaint(
                  painter: MinimapPainter(
                    map: map,
                    posX: posX,
                    posY: posY,
                    dirX: dirX,
                    dirY: dirY,
                  ),
                ),
              ),
            ),

            // ปุ่ม D-Pad สัมผัสบนหน้าจอ (สำหรับใช้เมาส์คลิกเดินได้)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Color(0xFF10B981)),
                      onPressed: () => _movePlayer(1, 0),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF10B981)),
                          onPressed: () => _movePlayer(0, -1),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Color(0xFF10B981)),
                          onPressed: () => _movePlayer(0, 1),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, color: Color(0xFF10B981)),
                      onPressed: () => _movePlayer(-1, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ตัวคำนวณและวาดลำแสง 3 มิติ (DDA Raycasting Engine)
class RaycasterPainter extends CustomPainter {
  final double posX, posY, dirX, dirY, planeX, planeY;
  final List<List<int>> map;

  RaycasterPainter({
    required this.posX,
    required this.posY,
    required this.dirX,
    required this.dirY,
    required this.planeX,
    required this.planeY,
    required this.map,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. วาดเพดานและพื้นแบบไล่เฉด
    final ceilingPaint = Paint()..color = const Color(0xFF0F172A);
    final floorPaint = Paint()..color = const Color(0xFF020617);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), ceilingPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2), floorPaint);

    final w = size.width;
    final h = size.height;
    const rayCount = 120; // จำนวนลำแสงที่ยิงกวาดสายตา
    final colW = w / rayCount;

    for (int x = 0; x < rayCount; x++) {
      final cameraX = 2 * x / rayCount - 1;
      final rayDirX = dirX + planeX * cameraX;
      final rayDirY = dirY + planeY * cameraX;

      int mapX = posX.toInt();
      int mapY = posY.toInt();

      final deltaDistX = (rayDirX == 0) ? 1e30 : (1 / rayDirX).abs();
      final deltaDistY = (rayDirY == 0) ? 1e30 : (1 / rayDirY).abs();

      double sideDistX;
      double sideDistY;
      int stepX;
      int stepY;

      if (rayDirX < 0) {
        stepX = -1;
        sideDistX = (posX - mapX) * deltaDistX;
      } else {
        stepX = 1;
        sideDistX = (mapX + 1.0 - posX) * deltaDistX;
      }

      if (rayDirY < 0) {
        stepY = -1;
        sideDistY = (posY - mapY) * deltaDistY;
      } else {
        stepY = 1;
        sideDistY = (mapY + 1.0 - posY) * deltaDistY;
      }

      int hit = 0;
      int side = 0;

      // อัลกอริทึม DDA วิ่งตรวจจับกำแพง
      while (hit == 0) {
        if (sideDistX < sideDistY) {
          sideDistX += deltaDistX;
          mapX += stepX;
          side = 0;
        } else {
          sideDistY += deltaDistY;
          mapY += stepY;
          side = 1;
        }
        if (mapX >= 0 && mapX < 12 && mapY >= 0 && mapY < 12) {
          if (map[mapX][mapY] > 0) hit = map[mapX][mapY];
        } else {
          break;
        }
      }

      double perpWallDist;
      if (side == 0) {
        perpWallDist = (sideDistX - deltaDistX);
      } else {
        perpWallDist = (sideDistY - deltaDistY);
      }

      if (perpWallDist <= 0.05) perpWallDist = 0.05;

      final lineHeight = (h / perpWallDist).clamp(0.0, h * 2);
      final drawStart = -lineHeight / 2 + h / 2;

      // สีของกำแพงตามชนิด และความลึกของแสง (Depth shading)
      Color wallColor = const Color(0xFF00F0FF);
      if (hit == 2) wallColor = const Color(0xFF10B981);
      if (hit == 3) wallColor = const Color(0xFFFF007A);

      // เงากำแพงด้านข้าง และความมืดตามระยะทาง
      if (side == 1) wallColor = Color.lerp(wallColor, Colors.black, 0.35)!;
      final fogFactor = (1.0 - (perpWallDist / 10.0)).clamp(0.1, 1.0);
      wallColor = wallColor.withOpacity(fogFactor);

      final wallPaint = Paint()..color = wallColor;
      canvas.drawRect(
        Rect.fromLTWH(x * colW, drawStart, colW + 0.5, lineHeight),
        wallPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// แผนที่เรดาร์ 2D ขนาดจิ๋ว
class MinimapPainter extends CustomPainter {
  final List<List<int>> map;
  final double posX, posY, dirX, dirY;

  MinimapPainter({
    required this.map,
    required this.posX,
    required this.posY,
    required this.dirX,
    required this.dirY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 12;
    final cellH = size.height / 12;

    for (int r = 0; r < 12; r++) {
      for (int c = 0; c < 12; c++) {
        if (map[r][c] > 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellW, r * cellH, cellW - 1, cellH - 1),
            Paint()..color = const Color(0xFF10B981).withOpacity(0.5),
          );
        }
      }
    }

    // จุดตัวผู้เล่น
    final playerPos = Offset(posY * cellW, posX * cellH);
    canvas.drawCircle(playerPos, 3.5, Paint()..color = Colors.redAccent);

    // ทิศทางที่มอง
    final lookDir = playerPos + Offset(dirY * 12, dirX * 12);
    canvas.drawLine(playerPos, lookDir, Paint()..color = Colors.yellowAccent..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =========================================================================
// 2. MODULE 2: BIONIC READING & NEURAL SPEED READER (RSVP 800 WPM)
// =========================================================================
class BionicSpeedReaderScreen extends StatefulWidget {
  const BionicSpeedReaderScreen({super.key});

  @override
  State<BionicSpeedReaderScreen> createState() => _BionicSpeedReaderScreenState();
}

class _BionicSpeedReaderScreenState extends State<BionicSpeedReaderScreen> {
  final String _sampleText = '''
Flutter is Google's portable UI toolkit for crafting beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Bionic Reading facilitates the reading process by guiding the eyes through text with artificial fixation points. As a result, the reader is only focusing on the highlighted initial letters and lets the brain organ complete the word. Neural speed reading with RSVP eliminates the eye movement delay, allowing users to absorb information up to 800 words per minute.
''';

  late List<String> _words;
  int _currentWordIndex = 0;
  bool _isPlaying = false;
  int _wpm = 450; // Words Per Minute
  Timer? _readerTimer;

  // โหมดแสดงผล (0: RSVP Flash Word, 1: Bionic Full Text)
  int _mode = 0;

  @override
  void initState() {
    super.initState();
    _words = _sampleText.trim().split(RegExp(r'\s+'));
  }

  void _togglePlay() {
    if (_isPlaying) {
      _readerTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      final ms = (60000 / _wpm).round();
      _readerTimer = Timer.periodic(Duration(milliseconds: ms), (timer) {
        if (_currentWordIndex < _words.length - 1) {
          setState(() => _currentWordIndex++);
        } else {
          _readerTimer?.cancel();
          setState(() {
            _isPlaying = false;
            _currentWordIndex = 0;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _readerTimer?.cancel();
    super.dispose();
  }

  // แยกคำทำ Bionic Reading (ทำตัวหนา 40-50% แรกของคำ)
  InlineSpan _buildBionicWord(String word) {
    if (word.length <= 1) {
      return TextSpan(text: word, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
    }
    final mid = (word.length * 0.45).ceil().clamp(1, word.length);
    final boldPart = word.substring(0, mid);
    final restPart = word.substring(mid);

    return TextSpan(
      children: [
        TextSpan(text: boldPart, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00F0FF))),
        TextSpan(text: '$restPart ', style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white70)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _words[_currentWordIndex];
    final midIndex = (currentWord.length / 2).floor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('🧠 BIONIC & RSVP SPEED READER',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          Row(
            children: [
              ChoiceChip(
                selected: _mode == 0,
                label: const Text('⚡ RSVP Flash'),
                selectedColor: const Color(0xFF00F0FF).withOpacity(0.2),
                onSelected: (val) => setState(() => _mode = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                selected: _mode == 1,
                label: const Text('📖 Bionic Text'),
                selectedColor: const Color(0xFF00F0FF).withOpacity(0.2),
                onSelected: (val) => setState(() => _mode = 1),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // หน้าจอแสดงผลการอ่าน
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00F0FF).withOpacity(0.08), blurRadius: 20),
                  ],
                ),
                child: _mode == 0
                    ? Center(
                        // โหมด RSVP Flash Word (ยิงคำศัพท์ทีละคำที่จุดกึ่งกลางสายตา)
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // เส้นนำสายตาสีแดง (Optimal Recognition Point)
                            Container(width: 2, height: 16, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(fontSize: 54, letterSpacing: 2),
                                children: [
                                  TextSpan(
                                    text: currentWord.substring(0, midIndex),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: currentWord.isNotEmpty ? currentWord[midIndex] : '',
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900),
                                  ),
                                  TextSpan(
                                    text: currentWord.length > midIndex + 1 ? currentWord.substring(midIndex + 1) : '',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(width: 2, height: 16, color: Colors.redAccent),
                            const SizedBox(height: 24),
                            Text('${_currentWordIndex + 1} / ${_words.length} คำ',
                                style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        // โหมด Bionic Reading (เน้นตัวหนาจุดสายตา)
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 22, height: 1.8),
                            children: _words.map(_buildBionicWord).toList(),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // แผงควบคุมความเร็ว WPM
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F0FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? 'PAUSE' : 'START READING', style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _togglePlay,
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.speed, color: Color(0xFF00F0FF)),
                  const SizedBox(width: 8),
                  Text('ความเร็ว: $_wpm WPM', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: _wpm.toDouble(),
                      min: 200,
                      max: 850,
                      divisions: 13,
                      activeColor: const Color(0xFF00F0FF),
                      onChanged: (val) {
                        setState(() {
                          _wpm = val.toInt();
                          if (_isPlaying) {
                            _togglePlay();
                            _togglePlay();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 3. MODULE 3: AUDIO OSCILLOSCOPE & FREQUENCY SYNTHESIZER
// =========================================================================
class AudioOscilloscopeScreen extends StatefulWidget {
  const AudioOscilloscopeScreen({super.key});

  @override
  State<AudioOscilloscopeScreen> createState() => _AudioOscilloscopeScreenState();
}

class _AudioOscilloscopeScreenState extends State<AudioOscilloscopeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  double _frequency = 440.0; // ความถี่มาตรฐานเสียงโน้ต A4 (440 Hz)
  double _amplitude = 0.8;
  String _waveformType = 'Sine'; // Sine, Square, Sawtooth, Triangle

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  // ยิงคลื่นความถี่เสียงจริงผ่าน Windows Audio Beeper
  Future<void> _playCurrentTone() async {
    final freq = _frequency.toInt().clamp(37, 32767);
    await io.Process.run('powershell', [
      '-Command',
      "[System.Console]::Beep($freq, 400)",
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('🌊 AUDIO OSCILLOSCOPE & FREQUENCY SYNTH',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // จอมอนิเตอร์ Oscilloscope สีเขียวนีออน CRT
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF02130C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withOpacity(0.2), blurRadius: 24),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: OscilloscopePainter(
                          phase: _waveController.value * 2 * pi,
                          frequency: _frequency,
                          amplitude: _amplitude,
                          waveformType: _waveformType,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // แผงควบคุมรูปคลื่นและความถี่
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: ['Sine', 'Square', 'Sawtooth', 'Triangle'].map((type) {
                          final isSel = _waveformType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              selected: isSel,
                              selectedColor: const Color(0xFF10B981).withOpacity(0.3),
                              label: Text(type, style: TextStyle(color: isSel ? const Color(0xFF10B981) : Colors.white70, fontWeight: FontWeight.bold)),
                              onSelected: (val) => setState(() => _waveformType = type),
                            ),
                          );
                        }).toList(),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        icon: const Icon(Icons.volume_up),
                        label: const Text('ยิงเสียงความถี่จริง (BEEP)', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _playCurrentTone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('ความถี่: ${_frequency.toInt()} Hz', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981))),
                      Expanded(
                        child: Slider(
                          value: _frequency,
                          min: 50,
                          max: 2000,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) => setState(() => _frequency = val),
                        ),
                      ),
                      Text('แอมพลิจูด: ${(_amplitude * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                      SizedBox(
                        width: 140,
                        child: Slider(
                          value: _amplitude,
                          min: 0.1,
                          max: 1.0,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) => setState(() => _amplitude = val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ตัววาดเส้นคลื่น Oscilloscope CRT เรืองแสง
class OscilloscopePainter extends CustomPainter {
  final double phase;
  final double frequency;
  final double amplitude;
  final String waveformType;

  OscilloscopePainter({
    required this.phase,
    required this.frequency,
    required this.amplitude,
    required this.waveformType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. วาดเส้นตารางเรดาร์ CRT กริดสีเขียวจาง
    final gridPaint = Paint()..color = const Color(0xFF10B981).withOpacity(0.08)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // เส้นแกนกลาง
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2),
        Paint()..color = const Color(0xFF10B981).withOpacity(0.25)..strokeWidth = 1.5);

    // 2. คำนวณจุดรูปคลื่น
    final path = Path();
    final midY = size.height / 2;
    final maxAmp = (size.height * 0.4) * amplitude;
    final waveLength = 400.0 / (frequency / 200);

    for (double x = 0; x < size.width; x += 2) {
      final t = (x / waveLength) * 2 * pi + phase;
      double yVal = 0;

      switch (waveformType) {
        case 'Sine':
          yVal = sin(t);
          break;
        case 'Square':
          yVal = sin(t) >= 0 ? 1.0 : -1.0;
          break;
        case 'Sawtooth':
          yVal = 2 * ((t / (2 * pi)) - (t / (2 * pi)).floor()) - 1;
          break;
        case 'Triangle':
          yVal = (2 / pi) * asin(sin(t));
          break;
      }

      final y = midY - (yVal * maxAmp);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // วาดเส้นคลื่นสะท้อนแสงนีออน (Glow)
    final glowPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.35)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}