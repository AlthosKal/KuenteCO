import 'package:flutter/material.dart';

class Background extends StatefulWidget {
  final Widget child;
  final bool showDefaultIfError;
  final Color? backgroundColor;
  final double? opacity;
  final AlignmentGeometry alignment;

  const Background({
    super.key,
    required this.child,
    this.showDefaultIfError = true,
    this.backgroundColor,
    this.opacity,
    this.alignment = Alignment.center,
  });

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  late ImageProvider _imageProvider;
  bool _imageError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _imageProvider = const AssetImage('assets/img/Background.png');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    try {
      final config = createLocalImageConfiguration(context);
      _imageProvider.resolve(config);
      if (mounted) {
        setState(() {
          _imageError = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageError = true;
          _isLoading = false;
        });
      }
      debugPrint('Background image error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo que cubre toda la pantalla
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: _imageError
                  ? null
                  : DecorationImage(
                image: _imageProvider,
                fit: BoxFit.cover, // Hace que la imagen cubra todo el fondo
                alignment: widget.alignment,
                colorFilter: widget.opacity != null
                    ? ColorFilter.mode(
                  Colors.black.withOpacity(widget.opacity!),
                  BlendMode.darken,
                )
                    : null,
              ),
              color: _imageError ? (widget.backgroundColor ?? Colors.white) : widget.backgroundColor,
            ),
          ),

          // Contenido
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}