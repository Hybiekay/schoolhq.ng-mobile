import 'package:flutter/material.dart';

class GlowBubble extends StatelessWidget {
  final double size;
  final double opacity;

  const GlowBubble({super.key, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
