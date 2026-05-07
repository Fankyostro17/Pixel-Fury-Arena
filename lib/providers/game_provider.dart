import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../services/network_service.dart';

class GameProvider with ChangeNotifier {
  Player? _localPlayer;
  final Map<String, Player> _otherPlayers = {};
  final List<Projectile> _projectiles = [];
  
  NetworkService? _networkService;
  bool _isGameRunning = false;
  int _score = 0;
  Duration _gameTime = Duration.zero;
  
  Player? get localPlayer => _localPlayer;
  Map<String, Player> get otherPlayers => Map.unmodifiable(_otherPlayers);
  List<Projectile> get projectiles => List.unmodifiable(_projectiles);
  bool get isGameRunning => _isGameRunning;
  int get score => _score;
  Duration get gameTime => _gameTime;
  
  void initializeGame(String playerId, String playerName) {
    _localPlayer = Player(
      id: playerId,
      name: playerName,
      position: Vector2D(1000, 1000), // Center of map
    );
    
    _networkService = NetworkService();
    _connectToServer();
    
    notifyListeners();
  }
  
  Future<void> _connectToServer() async {
    try {
      await _networkService!.connect();
      
      _networkService!.joinGame(_localPlayer!.id, _localPlayer!.name);
      
      _networkService!.messageStream.listen(_handleServerMessage);
      
      _isGameRunning = true;
      notifyListeners();
    } catch (e) {
      print('Failed to connect: $e');
      _isGameRunning = false;
      notifyListeners();
    }
  }
  
  void _handleServerMessage(Map<String, dynamic> message) {
    final type = message['type'];
    
    switch (type) {
      case 'player_joined':
        final player = Player.fromJson(message['player']);
        if (player.id != _localPlayer?.id) {
          _otherPlayers[player.id] = player;
        }
        break;
        
      case 'player_left':
        _otherPlayers.remove(message['playerId']);
        break;
        
      case 'player_moved':
        final playerId = message['playerId'] as String;
        final player = _otherPlayers[playerId];
        if (player != null) {
          player.position = Vector2D(
            message['x'] as double,
            message['y'] as double,
          );
        }
        break;
        
      case 'projectile_spawned':
        _projectiles.add(Projectile.fromJson(message['projectile']));
        break;
        
      case 'projectile_removed':
        _projectiles.removeWhere((p) => p.id == message['projectileId']);
        break;
        
      case 'player_hit':
        final playerId = message['playerId'] as String;
        final damage = message['damage'] as int;
        
        if (playerId == _localPlayer?.id) {
          _localPlayer!.takeDamage(damage);
        } else if (_otherPlayers.containsKey(playerId)) {
          _otherPlayers[playerId]!.takeDamage(damage);
        }
        break;
        
      case 'game_update':
        _gameTime = Duration(seconds: message['timeRemaining'] ?? 0);
        _score = message['score'] ?? 0;
        break;
    }
    
    notifyListeners();
  }
  
  void updateMovement(double dx, double dy, double delta) {
    if (_localPlayer == null || !_isGameRunning) return;
    
    final direction = Vector2D(dx, dy).normalized();
    _localPlayer!.move(direction, delta);
    
    // Keep player within bounds
    _localPlayer!.position.x = 
      _localPlayer!.position.x.clamp(0, GameConfig.mapWidth);
    _localPlayer!.position.y = 
      _localPlayer!.position.y.clamp(0, GameConfig.mapHeight);
    
    _networkService?.movePlayer(
      _localPlayer!.id,
      _localPlayer!.position.x,
      _localPlayer!.position.y,
    );
    
    notifyListeners();
  }
  
  void shootTowards(double targetX, double targetY) {
    if (_localPlayer == null || !_isGameRunning) return;
    
    final direction = Vector2D(
      targetX - _localPlayer!.position.x,
      targetY - _localPlayer!.position.y,
    ).normalized();
    
    final projectile = Projectile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: _localPlayer!.id,
      position: Vector2D(
        _localPlayer!.position.x,
        _localPlayer!.position.y,
      ),
      velocity: direction,
    );
    
    _projectiles.add(projectile);
    
    _networkService?.shoot(
      _localPlayer!.id,
      direction.x,
      direction.y,
    );
    
    notifyListeners();
  }
  
  void updateProjectiles(double delta) {
    for (final projectile in _projectiles) {
      projectile.update(delta);
      
      // Remove projectiles that go out of bounds
      if (projectile.position.x < 0 ||
          projectile.position.x > GameConfig.mapWidth ||
          projectile.position.y < 0 ||
          projectile.position.y > GameConfig.mapHeight) {
        projectile.isActive = false;
      }
    }
    
    _projectiles.removeWhere((p) => !p.isActive);
    
    // Check collisions
    _checkCollisions();
    
    notifyListeners();
  }
  
  void _checkCollisions() {
    for (final projectile in _projectiles) {
      if (!projectile.isActive) continue;
      
      // Check collision with other players
      for (final player in _otherPlayers.values) {
        if (!player.isAlive) continue;
        
        final distance = projectile.position.distanceTo(player.position);
        if (distance < GameConfig.playerRadius + GameConfig.projectileRadius) {
          projectile.isActive = false;
          player.takeDamage(projectile.damage.toInt());
          
          _networkService?.sendMessage('player_hit', {
            'playerId': player.id,
            'damage': projectile.damage.toInt(),
          });
          
          if (projectile.ownerId == _localPlayer?.id && !player.isAlive) {
            _score += 100;
          }
          
          break;
        }
      }
    }
  }
  
  void endGame() {
    _isGameRunning = false;
    _networkService?.disconnect();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _networkService?.disconnect();
    super.dispose();
  }
}
