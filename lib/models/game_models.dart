import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  Vector2D position;
  final double speed;
  int health;
  final int maxHealth;
  String characterType;
  bool isAlive;

  Player({
    required this.id,
    required this.name,
    required this.position,
    this.speed = 200.0,
    this.health = 100,
    this.maxHealth = 100,
    this.characterType = 'default',
    this.isAlive = true,
  });

  void move(Vector2D direction, double delta) {
    if (!isAlive) return;
    
    position.x += direction.x * speed * delta;
    position.y += direction.y * speed * delta;
  }

  void takeDamage(int damage) {
    health -= damage;
    if (health <= 0) {
      health = 0;
      isAlive = false;
    }
  }

  void heal(int amount) {
    health = (health + amount).clamp(0, maxHealth);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'x': position.x,
      'y': position.y,
      'health': health,
      'characterType': characterType,
      'isAlive': isAlive,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      position: Vector2D(json['x'], json['y']),
      health: json['health'],
      characterType: json['characterType'] ?? 'default',
      isAlive: json['isAlive'] ?? true,
    );
  }
}

class Vector2D {
  double x;
  double y;

  Vector2D(this.x, this.y);

  Vector2D operator +(Vector2D other) {
    return Vector2D(x + other.x, y + other.y);
  }

  Vector2D operator -(Vector2D other) {
    return Vector2D(x - other.x, y - other.y);
  }

  Vector2D operator *(double scalar) {
    return Vector2D(x * scalar, y * scalar);
  }

  double distanceTo(Vector2D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy).sqrt();
  }

  Vector2D normalized() {
    final length = (x * x + y * y).sqrt();
    if (length == 0) return Vector2D(0, 0);
    return Vector2D(x / length, y / length);
  }
}

class Projectile {
  final String id;
  final String ownerId;
  Vector2D position;
  Vector2D velocity;
  final double damage;
  final double speed;
  bool isActive;

  Projectile({
    required this.id,
    required this.ownerId,
    required this.position,
    required this.velocity,
    this.damage = 10.0,
    this.speed = 500.0,
    this.isActive = true,
  });

  void update(double delta) {
    if (!isActive) return;
    
    position.x += velocity.x * speed * delta;
    position.y += velocity.y * speed * delta;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'x': position.x,
      'y': position.y,
      'vx': velocity.x,
      'vy': velocity.y,
      'damage': damage,
      'isActive': isActive,
    };
  }

  factory Projectile.fromJson(Map<String, dynamic> json) {
    return Projectile(
      id: json['id'],
      ownerId: json['ownerId'],
      position: Vector2D(json['x'], json['y']),
      velocity: Vector2D(json['vx'], json['vy']),
      damage: json['damage'] ?? 10.0,
      isActive: json['isActive'] ?? true,
    );
  }
}

class GameConfig {
  static const double mapWidth = 2000.0;
  static const double mapHeight = 2000.0;
  static const int maxPlayers = 6;
  static const double playerRadius = 30.0;
  static const double projectileRadius = 8.0;
  
  static const Duration matchDuration = Duration(minutes: 3);
}
