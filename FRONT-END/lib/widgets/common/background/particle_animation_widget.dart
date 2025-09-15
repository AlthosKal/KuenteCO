import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Particle {
  Offset position;
  Offset direction;
  double speed;
  double size;
  double opacity;

  Particle({
    required this.position,
    required this.direction,
    this.speed = 2.0,
    this.size = 20.0,
    this.opacity = 0.7,
  });

  void move(Size screenSize) {
    position = position.translate(direction.dx * speed, direction.dy * speed);

    if (position.dx - size / 2 < 0 || position.dx + size / 2 > screenSize.width) {
      direction = Offset(-direction.dx, direction.dy);
    }
    if (position.dy - size / 2 < 0 || position.dy + size / 2 > screenSize.height) {
      direction = Offset(direction.dx, -direction.dy);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final ui.Image? particleImage;

  ParticlePainter(this.particles, {this.particleImage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      if (particleImage != null) {
        paint.colorFilter = ColorFilter.mode(
            Colors.white.withOpacity(particle.opacity),
            BlendMode.srcIn
        );

        final halfSize = particle.size / 2;
        final rect = Rect.fromLTWH(
          particle.position.dx - halfSize,
          particle.position.dy - halfSize,
          particle.size,
          particle.size,
        );

        canvas.drawImageRect(
          particleImage!,
          Rect.fromLTWH(0, 0, particleImage!.width.toDouble(), particleImage!.height.toDouble()),
          rect,
          paint,
        );
      } else {
        paint.color = Colors.white.withOpacity(particle.opacity);
        canvas.drawCircle(particle.position, particle.size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleAnimation extends StatefulWidget {
  const ParticleAnimation({super.key});

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation> with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;
  final int numberOfParticles = 40;
  final Random random = Random();
  Size? _screenSize;
  ui.Image? _particleImage;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 33) // ~30 FPS
    )..repeat();

    particles = [];
    _loadParticleImage();
    _controller.addListener(_updateParticles);
  }

  Future<void> _loadParticleImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/img/Logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();

      setState(() {
        _particleImage = fi.image;
      });
    } catch (e) {
      debugPrint('Error al cargar la imagen: $e');
      _createFallbackImage();
    }
  }

  void _createFallbackImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(20, 20);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());

    setState(() {
      _particleImage = img;
    });
  }

  void _initializeParticles() {
    if (_screenSize == null) return;

    particles = List.generate(numberOfParticles, (index) {
      return Particle(
        position: Offset(
          random.nextDouble() * _screenSize!.width,
          random.nextDouble() * _screenSize!.height,
        ),
        direction: _normalizedRandomDirection(),
        speed: 0.1 + random.nextDouble() * 0.1,
        size: 25.0 + random.nextDouble() * 35.0,
        opacity: 0.3 + random.nextDouble() * 0.7,
      );
    });
  }

  Offset _normalizedRandomDirection() {
    final dx = (random.nextDouble() * 2) - 1;
    final dy = (random.nextDouble() * 2) - 1;
    final magnitude = sqrt(dx * dx + dy * dy);
    return Offset(dx / magnitude, dy / magnitude);
  }

  void _updateParticles() {
    if (!mounted || _screenSize == null) return;

    for (final particle in particles) {
      particle.move(_screenSize!);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParticles);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF890cac),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          if (_screenSize == null || _screenSize != size) {
            _screenSize = size;
            _initializeParticles();
          }

          return RepaintBoundary(
            child: CustomPaint(
              painter: ParticlePainter(
                particles,
                particleImage: _particleImage,
              ),
              size: size,
            ),
          );
        },
      ),
    );
  }
}