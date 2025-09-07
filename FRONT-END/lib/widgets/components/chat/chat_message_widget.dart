import 'package:flutter/material.dart';
import 'typewriter_text_widget.dart';

enum MessageType { user, ai }

class ChatMessageWidget extends StatefulWidget {
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool enableTypewriter;
  final VoidCallback? onTypewriterComplete;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.type,
    required this.timestamp,
    this.enableTypewriter = false,
    this.onTypewriterComplete,
  }) : super(key: key);

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _showMessage = true;
    _slideController.forward();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.type == MessageType.ai 
          ? const Offset(-0.3, 0.0) 
          : const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.type == MessageType.ai) ...[
                _buildAvatar(),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.type == MessageType.user
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.type == MessageType.user
                            ? Colors.blue[600]
                            : Colors.grey[50],
                        borderRadius: _getBorderRadius(),
                        border: widget.type == MessageType.ai
                            ? Border.all(color: Colors.grey[200]!)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.type == MessageType.ai && widget.enableTypewriter)
                            TypewriterTextWidget(
                              text: widget.message,
                              speed: const Duration(milliseconds: 30),
                              textStyle: _getTextStyle(context),
                              onComplete: widget.onTypewriterComplete,
                            )
                          else
                            Text(
                              widget.message,
                              style: _getTextStyle(context),
                            ),
                          if (widget.type == MessageType.ai) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'IA Financiera',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(widget.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.type == MessageType.user) ...[
                const SizedBox(width: 12),
                _buildAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: widget.type == MessageType.ai ? Colors.blue[600] : Colors.grey[400],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        widget.type == MessageType.ai ? Icons.psychology : Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  BorderRadiusGeometry _getBorderRadius() {
    if (widget.type == MessageType.user) {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    return TextStyle(
      color: widget.type == MessageType.user ? Colors.white : Colors.grey[800],
      fontSize: 14,
      height: 1.4,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}