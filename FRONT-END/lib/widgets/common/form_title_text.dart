import 'package:flutter/material.dart';

class FormTitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;

  const FormTitleText({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      textAlign: textAlign,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontSize: fontSize,
      ),
    );
  }
}