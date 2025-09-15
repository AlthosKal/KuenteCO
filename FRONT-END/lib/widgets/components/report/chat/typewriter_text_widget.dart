import 'dart:async';

import 'package:flutter/material.dart';

class TypewriterTextWidget extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;
  final bool autoStart;

  const TypewriterTextWidget({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 50),
    this.textStyle,
    this.onComplete,
    this.autoStart = true,
  });

  @override
  State<TypewriterTextWidget> createState() => _TypewriterTextWidgetState();
}

class _TypewriterTextWidgetState extends State<TypewriterTextWidget>
    with SingleTickerProviderStateMixin {
  String _displayText = '';
  Timer? _timer;
  int _currentIndex = 0;
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _initCursorAnimation();
    if (widget.autoStart) {
      _startTypewriting();
    }
  }

  void _initCursorAnimation() {
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );
    _cursorController.repeat(reverse: true);
  }

  void _startTypewriting() {
    _currentIndex = 0;
    _displayText = '';
    _isComplete = false;

    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        _completeTypewriting();
      }
    });
  }

  void _completeTypewriting() {
    _timer?.cancel();
    _cursorController.stop();
    _cursorController.reset();
    setState(() {
      _displayText = widget.text;
      _isComplete = true;
    });
    widget.onComplete?.call();
  }

  void restart() {
    _timer?.cancel();
    _cursorController.repeat(reverse: true);
    _startTypewriting();
  }

  void complete() {
    _completeTypewriting();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorAnimation,
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: _displayText),
              if (!_isComplete)
                TextSpan(
                  text: '|',
                  style: TextStyle(
                    color: (widget.textStyle?.color ?? Colors.black)
                        .withOpacity(_cursorAnimation.value),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}