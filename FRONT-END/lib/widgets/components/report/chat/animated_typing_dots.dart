import 'package:flutter/material.dart';

class AnimatedTypingDots extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration animationDuration;

  const AnimatedTypingDots({
    super.key,
    this.color,
    this.size = 8.0,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<AnimatedTypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _animations.asMap().entries.map((entry) {
        return AnimatedBuilder(
          animation: entry.value,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
              decoration: BoxDecoration(
                color: color.withOpacity(entry.value.value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}