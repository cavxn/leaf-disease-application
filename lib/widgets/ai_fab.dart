import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/ai_chat_screen.dart';
import '../utils/app_theme.dart';

class AIFab extends StatefulWidget {
  const AIFab({super.key});

  @override
  State<AIFab> createState() => _AIFabState();
}

class _AIFabState extends State<AIFab> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _glowController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _glowController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _glowController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _glowController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: AppTheme.neonGradient.colors.first.withOpacity(0.3 * _pulseController.value),
                  blurRadius: 20 + (10 * _pulseController.value),
                  spreadRadius: 2,
                ),
                // Inner glow when pressed
                if (_isPressed)
                  BoxShadow(
                    color: AppTheme.neonGradient.colors.first.withOpacity(0.6 * _glowController.value),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(35),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const AIChatScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            )),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: const Duration(seconds: 3),
              color: Colors.white.withOpacity(0.3),
            );
        },
      ),
    );
  }
} 