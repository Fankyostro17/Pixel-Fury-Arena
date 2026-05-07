import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/player_widget.dart';
import '../widgets/projectile_widget.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/game_hud.dart';
import '../models/game_models.dart';

class GameScreen extends StatefulWidget {
  final String playerName;

  const GameScreen({super.key, required this.playerName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameProvider _gameProvider;
  late Ticker _ticker;
  
  double _cameraX = 1000;
  double _cameraY = 1000;
  
  DateTime? _lastFrameTime;
  bool _isAimingMode = false;
  Offset _aimTarget = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    _gameProvider = context.read<GameProvider>();
    _gameProvider.initializeGame(
      DateTime.now().millisecondsSinceEpoch.toString(),
      widget.playerName,
    );
    
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _gameProvider.endGame();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastFrameTime != null) {
      final delta = (DateTime.now().difference(_lastFrameTime!)).inMilliseconds / 1000.0;
      _gameProvider.updateProjectiles(delta);
      
      // Update camera to follow player
      if (_gameProvider.localPlayer != null) {
        setState(() {
          _cameraX = _gameProvider.localPlayer!.position.x;
          _cameraY = _gameProvider.localPlayer!.position.y;
        });
      }
    }
    _lastFrameTime = DateTime.now();
  }

  void _onMove(double dx, double dy) {
    if (_lastFrameTime != null) {
      final delta = (DateTime.now().difference(_lastFrameTime!)).inMilliseconds / 1000.0;
      _gameProvider.updateMovement(dx, dy, delta);
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isAimingMode = true;
      _aimTarget = details.localPosition;
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (_isAimingMode && _gameProvider.localPlayer != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      
      // Convert screen coordinates to world coordinates
      final worldX = _aimTarget.dx + _cameraX - screenWidth / 2;
      final worldY = _aimTarget.dy + _cameraY - screenHeight / 2;
      
      _gameProvider.shootTowards(worldX, worldY);
    }
    
    setState(() {
      _isAimingMode = false;
    });
  }

  void _onShootPressed() {
    if (_gameProvider.localPlayer != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      
      // Shoot towards center-top of screen
      final worldX = _cameraX + (screenWidth / 4);
      final worldY = _cameraY - (screenHeight / 4);
      
      _gameProvider.shootTowards(worldX, worldY);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Stack(
            children: [
              // Game map background
              _buildGameMap(),
              
              // Projectiles
              ...gameProvider.projectiles.map((projectile) {
                return ProjectileWidget(
                  x: projectile.position.x,
                  y: projectile.position.y,
                  ownerId: projectile.ownerId,
                  isLocalPlayerProjectile: projectile.ownerId == gameProvider.localPlayer?.id,
                  cameraX: _cameraX,
                  cameraY: _cameraY,
                );
              }),
              
              // Other players
              ...gameProvider.otherPlayers.values.map((player) {
                return PlayerWidget(
                  playerId: player.id,
                  name: player.name,
                  x: player.position.x,
                  y: player.position.y,
                  health: player.health,
                  maxHealth: player.maxHealth,
                  isLocalPlayer: false,
                  characterType: player.characterType,
                  isAlive: player.isAlive,
                  cameraX: _cameraX,
                  cameraY: _cameraY,
                );
              }),
              
              // Local player
              if (gameProvider.localPlayer != null)
                PlayerWidget(
                  playerId: gameProvider.localPlayer!.id,
                  name: gameProvider.localPlayer!.name,
                  x: gameProvider.localPlayer!.position.x,
                  y: gameProvider.localPlayer!.position.y,
                  health: gameProvider.localPlayer!.health,
                  maxHealth: gameProvider.localPlayer!.maxHealth,
                  isLocalPlayer: true,
                  characterType: gameProvider.localPlayer!.characterType,
                  isAlive: gameProvider.localPlayer!.isAlive,
                  cameraX: _cameraX,
                  cameraY: _cameraY,
                ),
              
              // Aiming indicator
              if (_isAimingMode)
                Positioned(
                  left: _aimTarget.dx - 20,
                  top: _aimTarget.dy - 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.target,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
              
              // Virtual joystick for movement
              Positioned(
                bottom: 20,
                left: 20,
                child: VirtualJoystick(
                  onMove: _onMove,
                  size: 150,
                ),
              ),
              
              // HUD
              if (gameProvider.localPlayer != null)
                GameHUD(
                  score: gameProvider.score,
                  gameTime: gameProvider.gameTime,
                  playerHealth: gameProvider.localPlayer!.health,
                  maxHealth: gameProvider.localPlayer!.maxHealth,
                  playerName: gameProvider.localPlayer!.name,
                  onShootPressed: _onShootPressed,
                ),
              
              // Touch layer for aiming
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameMap() {
    return CustomPaint(
      size: Size.infinite,
      painter: MapPainter(
        cameraX: _cameraX,
        cameraY: _cameraY,
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final double cameraX;
  final double cameraY;

  MapPainter({
    required this.cameraX,
    required this.cameraY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    
    // Calculate visible area in world coordinates
    final left = cameraX - screenWidth / 2;
    final top = cameraY - screenHeight / 2;
    final right = cameraX + screenWidth / 2;
    final bottom = cameraY + screenHeight / 2;
    
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..strokeWidth = 1;
    
    const gridSize = 100.0;
    final startX = (left ~/ gridSize) * gridSize;
    final startY = (top ~/ gridSize) * gridSize;
    
    for (double x = startX; x <= right; x += gridSize) {
      final screenX = x - cameraX + screenWidth / 2;
      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, screenHeight),
        gridPaint,
      );
    }
    
    for (double y = startY; y <= bottom; y += gridSize) {
      final screenY = y - cameraY + screenHeight / 2;
      canvas.drawLine(
        Offset(0, screenY),
        Offset(screenWidth, screenY),
        gridPaint,
      );
    }
    
    // Draw map boundaries
    final boundaryPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final mapLeft = 0 - cameraX + screenWidth / 2;
    final mapTop = 0 - cameraY + screenHeight / 2;
    final mapRight = GameConfig.mapWidth - cameraX + screenWidth / 2;
    final mapBottom = GameConfig.mapHeight - cameraY + screenHeight / 2;
    
    canvas.drawRect(
      Rect.fromLTWH(mapLeft, mapTop, mapRight - mapLeft, mapBottom - mapTop),
      boundaryPaint,
    );
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) {
    return oldDelegate.cameraX != cameraX || oldDelegate.cameraY != cameraY;
  }
}
