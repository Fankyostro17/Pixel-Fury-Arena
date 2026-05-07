import 'package:flutter/material.dart';

class VirtualJoystick extends StatefulWidget {
  final Function(double, double) onMove;
  final double size;
  final Color? color;

  const VirtualJoystick({
    super.key,
    required this.onMove,
    this.size = 150.0,
    this.color,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _stickPosition = Offset.zero;
  bool _isDragging = false;
  
  late double _radius;
  late double _stickRadius;

  @override
  void initState() {
    super.initState();
    _radius = widget.size / 2;
    _stickRadius = widget.size / 5;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: JoystickPainter(
            stickPosition: _stickPosition,
            radius: _radius,
            stickRadius: _stickRadius,
            color: widget.color ?? Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _stickPosition += details.delta;
      
      // Constrain stick within the base circle
      final distance = _stickPosition.distance;
      if (distance > _radius - _stickRadius) {
        final angle = _stickPosition.direction;
        _stickPosition = Offset.fromDirection(
          angle,
          _radius - _stickRadius,
        );
      }
      
      // Calculate normalized direction
      final normalizedX = _stickPosition.dx / (_radius - _stickRadius);
      final normalizedY = _stickPosition.dy / (_radius - _stickRadius);
      
      widget.onMove(normalizedX, normalizedY);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _stickPosition = Offset.zero;
    });
    
    widget.onMove(0, 0);
  }
}

class JoystickPainter extends CustomPainter {
  final Offset stickPosition;
  final double radius;
  final double stickRadius;
  final Color color;

  JoystickPainter({
    required this.stickPosition,
    required this.radius,
    required this.stickRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw base circle
    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, basePaint);
    
    // Draw base border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, borderPaint);
    
    // Draw stick
    final stickPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      center + stickPosition,
      stickRadius,
      stickPaint,
    );
    
    // Draw stick border
    final stickBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(
      center + stickPosition,
      stickRadius,
      stickBorderPaint,
    );
  }

  @override
  bool shouldRepaint(JoystickPainter oldDelegate) {
    return oldDelegate.stickPosition != stickPosition;
  }
}
