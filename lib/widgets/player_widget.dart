import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayerWidget extends StatelessWidget {
  final String playerId;
  final String name;
  final double x;
  final double y;
  final int health;
  final int maxHealth;
  final bool isLocalPlayer;
  final String characterType;
  final bool isAlive;
  final double cameraX;
  final double cameraY;

  const PlayerWidget({
    super.key,
    required this.playerId,
    required this.name,
    required this.x,
    required this.y,
    required this.health,
    required this.maxHealth,
    required this.isLocalPlayer,
    required this.characterType,
    required this.isAlive,
    required this.cameraX,
    required this.cameraY,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate screen position relative to camera
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final screenX = x - cameraX + screenWidth / 2;
    final screenY = y - cameraY + screenHeight / 2;
    
    // Don't render if off-screen
    if (screenX < -50 || screenX > screenWidth + 50 ||
        screenY < -50 || screenY > screenHeight + 50) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: screenX - 30,
      top: screenY - 30,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Health bar
            _buildHealthBar(),
            
            // Player character SVG
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocalPlayer ? Colors.yellow : Colors.white,
                  width: isLocalPlayer ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAlive ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildCharacterSVG(),
              ),
            ),
            
            // Player name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar() {
    final healthPercent = health / maxHealth;
    
    return Container(
      width: 60,
      height: 6,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: healthPercent,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  healthPercent > 0.5 
                    ? Colors.green 
                    : healthPercent > 0.25 
                      ? Colors.orange 
                      : Colors.red,
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSVG() {
    // Default character SVG - can be customized based on characterType
    final svgString = '''
      <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <circle cx="50" cy="50" r="45" fill="${isAlive ? '#4CAF50' : '#9E9E9E'}"/>
        <circle cx="35" cy="40" r="8" fill="white"/>
        <circle cx="65" cy="40" r="8" fill="white"/>
        <circle cx="35" cy="40" r="4" fill="black"/>
        <circle cx="65" cy="40" r="4" fill="black"/>
        <path d="M 30 65 Q 50 80 70 65" stroke="white" stroke-width="4" fill="none"/>
        ${isLocalPlayer ? '<circle cx="50" cy="50" r="40" stroke="yellow" stroke-width="3" fill="none"/>' : ''}
      </svg>
    ''';
    
    return SvgPicture.string(
      svgString,
      fit: BoxFit.cover,
    );
  }
}
