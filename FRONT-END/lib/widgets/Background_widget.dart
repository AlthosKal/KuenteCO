import 'package:flutter/material.dart';
import 'dart:math';

class Background extends StatefulWidget {
  final Widget child;

  const Background({
    super.key,
    required this.child,
  });

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  final Random _random = Random();
  late List<Offset> _particlePositions;
  late Size _screenSize;

  @override
  void initState() {
    super.initState();
    _particlePositions = [];
    _screenSize = Size.zero;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateParticlePositions();
    });
  }

  void _generateParticlePositions() {
    const particleCount = 25;
    const minDistance = 120.0;
    final newParticlePositions = <Offset>[];

    for (int i = 0; i < particleCount; i++) {
      bool positionValid;
      Offset newPosition;
      int attempts = 0;

      do {
        positionValid = true;
        newPosition = Offset(
          _random.nextDouble() * _screenSize.width,
          _random.nextDouble() * _screenSize.height,
        );

        for (final position in newParticlePositions) {
          if ((position - newPosition).distance < minDistance) {
            positionValid = false;
            break;
          }
        }

        attempts++;
        if (attempts > 100) break;
      } while (!positionValid && attempts <= 100);

      newParticlePositions.add(newPosition);
    }
    setState(() => _particlePositions = newParticlePositions);
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Fondo con gradiente profesional
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.indigo.shade900,
                Colors.purple.shade800,
                Colors.deepPurple.shade700,
              ],
              stops: const [0.1, 0.5, 1.0],
            ),
          ),
        ),

        // Patrón geométrico de fondo
        Positioned.fill(
          child: CustomPaint(
            painter: _FinancialPatternPainter(),
          ),
        ),

        // Elementos financieros estáticos
        ..._buildStaticElements(),

        // Gráficos circulares decorativos
        Positioned(
          top: 100,
          right: -50,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _DonutChartPainter(
              colors: [
                Colors.tealAccent.withOpacity(0.3),
                Colors.blueAccent.withOpacity(0.3),
                Colors.purpleAccent.withOpacity(0.3),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: -80,
          left: -80,
          child: CustomPaint(
            size: const Size(250, 250),
            painter: _DonutChartPainter(
              colors: [
                Colors.tealAccent.withOpacity(0.3),
                Colors.blueAccent.withOpacity(0.3),
                Colors.purpleAccent.withOpacity(0.3),
              ],
            ),
          ),
        ),

        // Partículas fijas bien distribuidas
        ..._buildFixedParticles(),

        // Contenido principal
        widget.child,
      ],
    );
  }

  List<Widget> _buildStaticElements() {
    return [
      _buildStaticElement(Icons.currency_bitcoin, 50, 100),
      _buildStaticElement(Icons.trending_up, _screenSize.width - 100, 150),
      _buildStaticElement(Icons.account_balance, 80, _screenSize.height - 200),
      _buildStaticElement(Icons.pie_chart, _screenSize.width - 120, _screenSize.height - 150),
      _buildStaticElement(Icons.monetization_on, _screenSize.width / 2, 70),
      _buildStaticElement(Icons.bar_chart, 40, _screenSize.height / 2),
      _buildStaticElement(Icons.savings, _screenSize.width - 60, _screenSize.height / 3),
    ];
  }

  Widget _buildStaticElement(IconData icon, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: 0.15,
        child: Icon(icon, size: 80, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildFixedParticles() {
    return _particlePositions.map((position) {
      return Positioned(
        left: position.dx,
        top: position.dy,
        child: Icon(
          _random.nextBool() ? Icons.attach_money : Icons.currency_exchange,
          size: 16 + _random.nextDouble() * 12,
          color: [
            Colors.white,
            Colors.blueAccent,
            Colors.purpleAccent,
            Colors.tealAccent,
          ][_random.nextInt(4)].withOpacity(0.7),
        ),
      );
    }).toList();
  }
}

class _FinancialPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Líneas diagonales
    for (double i = -size.height; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Círculos concéntricos
    final center = Offset(size.width / 2, size.height / 2);
    for (double radius = 50; radius < size.width / 2; radius += 60) {
      canvas.drawCircle(
        center,
        radius,
        paint..color = Colors.white.withOpacity(0.02),
      );
    }

    // Puntos de conexión
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 80) {
      for (double y = 0; y < size.height; y += 80) {
        if ((x + y) % 160 == 0) {
          canvas.drawCircle(Offset(x, y), 2, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  final List<Color> colors;

  const _DonutChartPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 10);
    const sweepAngle = 2 * pi;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        rect,
        -pi / 2 + (i * sweepAngle / colors.length),
        sweepAngle / colors.length - 0.2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}