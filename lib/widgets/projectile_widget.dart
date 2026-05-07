import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProjectileWidget extends StatelessWidget {
  final double x;
  final double y;
  final String ownerId;
  final bool isLocalPlayerProjectile;
  final double cameraX;
  final double cameraY;

  const ProjectileWidget({
    super.key,
    required this.x,
    required this.y,
    required this.ownerId,
    required this.isLocalPlayerProjectile,
    required this.cameraX,
    required this.cameraY,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final screenX = x - cameraX + screenWidth / 2;
    final screenY = y - cameraY + screenHeight / 2;
    
    // Don't render if off-screen
    if (screenX < -20 || screenX > screenWidth + 20 ||
        screenY < -20 || screenY > screenHeight + 20) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: screenX - 8,
      top: screenY - 8,
      child: _buildProjectileSVG(),
    );
  }

  Widget _buildProjectileSVG() {
    final color = isLocalPlayerProjectile ? '#FFEB3B' : '#FF5722';
    
    final svgString = '''
      <svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
        <circle cx="16" cy="16" r="14" fill="$color"/>
        <circle cx="16" cy="16" r="10" fill="${isLocalPlayerProjectile ? '#FFF9C4' : '#FFCCBC'}"/>
        <circle cx="16" cy="16" r="6" fill="$color"/>
      </svg>
    ''';
    
    return SvgPicture.string(
      svgString,
      width: 16,
      height: 16,
    );
  }
}
