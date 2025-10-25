import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../utils/app_theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  bool _isLoading = false;
  late AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Add welcome message
    _messages.add(ChatMessage(
      message: "Hello! I'm your AI plant assistant. I can help you with plant care, disease identification, and gardening tips. How can I assist you today?",
      sender: ChatSender.ai,
    ));
  }

  @override
  void dispose() {
    _typingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(message: text, sender: ChatSender.user));
      _controller.clear();
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final aiReply = await _aiService.sendMessage(text);
      setState(() {
        _messages.add(ChatMessage(message: aiReply, sender: ChatSender.ai));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          message: 'Sorry, I encountered an error. Please try again.',
          sender: ChatSender.ai,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.cyberGradient : AppTheme.neonGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Futuristic App Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.neonGradient,
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Assistant',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Plant Care Expert',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutCubic),

              // Chat Messages
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoading) {
                          return _buildTypingIndicator();
                        }
                        
                        final msg = _messages[index];
                        return _buildMessageBubble(msg, index);
                      },
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

              // Input Area
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                  borderRadius: BorderRadius.circular(25),
                  border: isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ask me anything about plants...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.neonGradient,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: _isLoading ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = msg.sender == ChatSender.user;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.neonGradient,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                  ? AppTheme.neonGradient.colors.first.withOpacity(0.9)
                  : isDark ? AppTheme.glassmorphismDark.color : AppTheme.glassmorphismLight.color,
                borderRadius: BorderRadius.circular(20),
                border: isUser ? null : (isDark ? AppTheme.glassmorphismDark.border : AppTheme.glassmorphismLight.border),
                boxShadow: [
                  BoxShadow(
                    color: isUser 
                      ? AppTheme.neonGradient.colors.first.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                msg.message,
                style: TextStyle(
                  color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate().slideX(
      begin: isUser ? 0.3 : -0.3,
      duration: 400.ms,
      delay: (index * 100).ms,
      curve: Curves.easeOutCubic,
    ).fadeIn(
      duration: 400.ms,
      delay: (index * 100).ms,
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.neonGradient,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.glassmorphismDark.color,
              borderRadius: BorderRadius.circular(20),
              border: AppTheme.glassmorphismDark.border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animation = (delay + _typingController.value) % 1.0;
        final opacity = (animation * 2).clamp(0.0, 1.0);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.neonGradient.colors.first.withOpacity(opacity),
          ),
        );
      },
    );
  }
} 