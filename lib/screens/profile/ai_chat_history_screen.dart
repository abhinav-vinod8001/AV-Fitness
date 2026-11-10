import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/ai_insights_provider.dart';
import '../../models/coach_message_model.dart';
import '../../core/utils/app_animations.dart';

class AiChatHistoryScreen extends ConsumerStatefulWidget {
  const AiChatHistoryScreen({super.key});

  @override
  ConsumerState<AiChatHistoryScreen> createState() => _AiChatHistoryScreenState();
}

class _AiChatHistoryScreenState extends ConsumerState<AiChatHistoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    HapticFeedback.lightImpact();
    _textController.clear();
    _focusNode.unfocus();
    
    // Slight delay to allow UI to update before scrolling
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    await ref.read(aiCoachProvider.notifier).sendMessage(text);
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _clearHistory() async {
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('This will delete all saved conversations with Coach. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(aiCoachProvider.notifier).clearChatHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat history cleared')),
        );
      }
    }
  }

  void _copyAll(List<CoachMessage> messages) {
    if (messages.isEmpty) return;
    HapticFeedback.lightImpact();
    final text = messages.map((m) {
      final role = m.isCoach ? 'Coach' : 'You';
      final time = DateFormat('MMM d, h:mm a').format(m.timestamp);
      return '[$time] $role: ${m.content}';
    }).join('\n\n');

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversation copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachState = ref.watch(aiCoachProvider);
    final messages = coachState.messages;
    final isTyping = coachState.isTyping;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'New Chat',
            onPressed: _clearHistory,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              AppAnimations.showAnimatedBottomSheet(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.copy_rounded),
                        title: const Text('Copy Conversation'),
                        onTap: () {
                          Navigator.pop(ctx);
                          _copyAll(messages);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        title: const Text('Clear History', style: TextStyle(color: Colors.redAccent)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _clearHistory();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade500],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AI Coach',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Recent Chats',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('Current Session', style: TextStyle(fontWeight: FontWeight.w600)),
                selected: true,
                selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
                selectedColor: cs.primary,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile/settings');
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.auto_awesome, color: cs.primary, size: 36),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'How can I help you today?',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask me for workout advice, form tips, or motivation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildQuickPrompt('Give me a motivation boost'),
                              _buildQuickPrompt('How is my progress?'),
                              _buildQuickPrompt('Suggest a recovery routine'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isTyping) {
                        return _buildTypingIndicator(cs);
                      }
                      final message = messages[index];
                      return _buildChatBubble(message, cs, isDark);
                    },
                  ),
          ),
          _buildMessageInput(cs, isDark, isTyping),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String prompt) {
    return ActionChip(
      label: Text(prompt, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _handleSubmitted(prompt);
      },
    );
  }

  Widget _buildChatBubble(CoachMessage message, ColorScheme cs, bool isDark) {
    final isMe = !message.isCoach;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe 
                    ? cs.primary 
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                border: isMe ? null : Border.all(
                  color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                  width: 1,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isMe ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 48), // Padding on the left for user messages
          ] else ...[
            const SizedBox(width: 48), // Padding on the right for AI messages
          ]
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade500],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: const SizedBox(
              width: 40,
              height: 10,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme cs, bool isDark, bool isTyping) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      enabled: !isTyping,
                      decoration: InputDecoration(
                        hintText: 'Message Coach...',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: isTyping ? null : _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isTyping ? null : LinearGradient(
                        colors: [cs.primary, cs.tertiary],
                      ),
                      color: isTyping ? cs.surfaceContainerHighest : null,
                      shape: BoxShape.circle,
                      boxShadow: isTyping ? [] : [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: isTyping ? cs.onSurfaceVariant : Colors.white, size: 20),
                      onPressed: isTyping ? null : () => _handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
