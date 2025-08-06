import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArrowNavigableField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode inputFocusNode;
  final int index;
  final int totalFields;
  final void Function(String, int) onChanged;
  final List<FocusNode> focusNodes;

  const ArrowNavigableField({
    super.key,
    required this.controller,
    required this.inputFocusNode,
    required this.index,
    required this.totalFields,
    required this.onChanged,
    required this.focusNodes,
  });

  @override
  State<ArrowNavigableField> createState() => _ArrowNavigableFieldState();
}

class _ArrowNavigableFieldState extends State<ArrowNavigableField> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && widget.index > 0) {
      widget.focusNodes[widget.index - 1].requestFocus();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        widget.index < widget.totalFields - 1) {
      widget.focusNodes[widget.index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: _handleKeyEvent,
      child: SizedBox(
        width: 40,
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.inputFocusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 22),
          decoration: const InputDecoration(
            counterText: '',
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.length > 1) {
              value = value[0];
              widget.controller.text = value;
              widget.controller.selection = const TextSelection.collapsed(offset: 1);
            }

            widget.onChanged(value, widget.index);

            if (value.isNotEmpty && widget.index < widget.totalFields - 1) {
              widget.focusNodes[widget.index + 1].requestFocus();
            }
          },
          onEditingComplete: () {
            if (widget.index < widget.totalFields - 1) {
              widget.focusNodes[widget.index + 1].requestFocus();
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    );
  }
}
