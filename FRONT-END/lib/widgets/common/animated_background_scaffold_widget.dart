import 'package:flutter/material.dart';
import 'package:kuenteco/widgets/common/particle_animation_widget.dart';

class AnimatedBackgroundScaffold extends StatelessWidget {
  final Widget child;

  const AnimatedBackgroundScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleAnimation()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}