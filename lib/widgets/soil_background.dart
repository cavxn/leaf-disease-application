import 'package:flutter/material.dart';

class SoilBackground extends StatelessWidget {
  final Widget child;
  const SoilBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/soil_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          ),
        ),
        child,
      ],
    );
  }
} 