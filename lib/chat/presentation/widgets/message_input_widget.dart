import 'package:flutter/material.dart';
import '../theme/chat_colors.dart';

/// Widget personalizado para input de mensajes
class MessageInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final String hintText;
  final bool isEnabled;

  const MessageInputWidget({
    super.key,
    required this.controller,
    this.onSend,
    this.hintText = 'Escribe un mensaje...',
    this.isEnabled = true,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onSendPressed() {
    if (_hasText && widget.onSend != null && widget.isEnabled) {
      widget.onSend!();
      widget.controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: ChatColors.background,
        border: Border(
          top: BorderSide(
            color: ChatColors.cardBackground,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ChatColors.fieldBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      enabled: widget.isEnabled,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        color: ChatColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: const TextStyle(
                          color: ChatColors.textSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _hasText ? (_) => _onSendPressed() : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _onSendPressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasText && widget.isEnabled 
                    ? ChatColors.accent 
                    : ChatColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: _hasText && widget.isEnabled 
                    ? ChatColors.textPrimary 
                    : ChatColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}