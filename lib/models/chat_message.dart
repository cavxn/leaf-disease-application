import 'package:flutter/foundation.dart';

enum ChatSender { user, ai }

class ChatMessage {
  final String message;
  final ChatSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.sender,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
} 