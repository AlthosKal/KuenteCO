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
        fit: StackFit.expand,
        children: [
          // Fondo
          if (!_isLoading)
            _buildBackground(),

          // Contenido
          widget.child,
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_imageError && !widget.showDefaultIfError) {
      return Container();
    }

    return _imageError
        ? Container(color: widget.backgroundColor ?? Colors.white)
        : Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _imageProvider,
          fit: BoxFit.cover,
          alignment: widget.alignment,
          colorFilter: widget.opacity != null
              ? ColorFilter.mode(
            Colors.black.withOpacity(widget.opacity!),
            BlendMode.darken,
          )
              : null,
        ),
        color: widget.backgroundColor,
      ),
    );
  }
}