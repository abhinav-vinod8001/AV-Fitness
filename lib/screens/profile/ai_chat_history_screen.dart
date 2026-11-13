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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    await ref.read(aiCoachProvider.notifier).sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _startNewChat() async {
    HapticFeedback.mediumImpact();
    await ref.read(aiCoachProvider.notifier).startNewChat();
    if (!mounted) return;
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    _scrollToBottom();
  }

  Future<void> _showRenameDialog(String sessionId, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await ref.read(aiCoachProvider.notifier).renameSession(sessionId, controller.text.trim());
    }
  }

  Future<void> _confirmDeleteSession(String sessionId, String title) async {
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: Text('Delete "$title"? This local conversation will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(aiCoachProvider.notifier).deleteSession(sessionId);
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Chat History?'),
        content: const Text(
          'This will permanently delete all locally saved conversations with Coach. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(aiCoachProvider.notifier).clearChatHistory();
      if (mounted) {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local chat history cleared')),
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

  void _copyMessage(String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied!')),
    );
  }

  void _showContextDetails(Map<String, dynamic> summary) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final hasActive = summary['hasActiveWorkout'] == true;
        final activeName = summary['activeWorkoutName'] ?? '';
        final totalWorkouts = summary['totalWorkouts'] ?? 0;
        final watchConnected = summary['wearableConnected'] == true;
        final hr = summary['heartRate'];
        final goal = summary['goal'] ?? 'Strength';
        final athlete = summary['athleteName'] ?? 'Athlete';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_rounded, color: Colors.orange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Coach Context',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Data loaded into Coach for this conversation',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildContextTile(
                  Icons.person_outline,
                  'Athlete Profile',
                  '$athlete • Goal: $goal',
                  cs,
                ),
                _buildContextTile(
                  Icons.fitness_center_rounded,
                  'Training History',
                  '$totalWorkouts total workouts logged on device',
                  cs,
                ),
                if (hasActive)
                  _buildContextTile(
                    Icons.play_circle_fill_rounded,
                    'Live In-Gym Status',
                    'Active workout: "$activeName" in progress!',
                    cs,
                    highlightColor: Colors.greenAccent,
                  )
                else
                  _buildContextTile(
                    Icons.pause_circle_outline_rounded,
                    'Live Status',
                    'Outside gym / Resting',
                    cs,
                  ),
                _buildContextTile(
                  Icons.watch_rounded,
                  'Galaxy Watch Integration',
                  watchConnected
                      ? 'Connected (${hr != null ? '$hr BPM live' : 'Active sync'})'
                      : 'Disconnected',
                  cs,
                  highlightColor: watchConnected ? Colors.greenAccent : null,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All training data and chat histories are stored 100% locally on your device.',
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextTile(IconData icon, String title, String subtitle, ColorScheme cs, {Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: highlightColor ?? cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: highlightColor ?? cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachState = ref.watch(aiCoachProvider);
    final messages = coachState.messages;
    final isTyping = coachState.isTyping;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = coachState.contextSummary;

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('AI Coach', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(
              coachState.activeSessionTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: 'Chat History',
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'New Chat',
            onPressed: _startNewChat,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'rename') {
                _showRenameDialog(coachState.activeSessionId, coachState.activeSessionTitle);
              } else if (val == 'copy') {
                _copyAll(messages);
              } else if (val == 'clear') {
                _confirmDeleteSession(coachState.activeSessionId, coachState.activeSessionTitle);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Rename Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Copy Conversation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Delete This Chat', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildSessionsDrawer(coachState, cs, isDark),
      body: Column(
        children: [
          // Contextual Awareness Pill
          _buildContextPill(summary, cs, isDark),

          // Message Stream / Empty State
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(summary, cs, isDark)
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

          // Dynamic Contextual Suggestion Chips
          _buildSuggestionChips(summary, cs, isDark),

          // Message Input Field
          _buildMessageInput(cs, isDark, isTyping),
        ],
      ),
    );
  }

  /// Interactive pill showing live contextual data loaded
  Widget _buildContextPill(Map<String, dynamic> summary, ColorScheme cs, bool isDark) {
    final hasActive = summary['hasActiveWorkout'] == true;
    final activeName = summary['activeWorkoutName'] ?? '';
    final watchConnected = summary['wearableConnected'] == true;
    final totalWorkouts = summary['totalWorkouts'] ?? 0;

    return GestureDetector(
      onTap: () => _showContextDetails(summary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasActive
              ? Colors.redAccent.withValues(alpha: 0.15)
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasActive
                ? Colors.redAccent.withValues(alpha: 0.5)
                : (isDark ? Colors.white10 : Colors.black12),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: hasActive
                    ? Colors.redAccent
                    : (watchConnected ? Colors.greenAccent : Colors.amber),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                hasActive
                    ? 'IN GYM: $activeName • Coach Active'
                    : 'Coach Connected: $totalWorkouts workouts • ${watchConnected ? "Watch Synced" : "On-Device Storage"}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasActive ? Colors.redAccent : cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  /// Local Sessions Drawer
  Widget _buildSessionsDrawer(AiCoachState state, ColorScheme cs, bool isDark) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.orange.shade500],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chat History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Stored 100% locally on device', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Start New Chat Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: ElevatedButton.icon(
                onPressed: _startNewChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Start New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const Divider(height: 24),

            // Recent Sessions List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SAVED CONVERSATIONS (${state.sessions.length})',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            Expanded(
              child: state.sessions.isEmpty
                  ? Center(
                      child: Text(
                        'No saved chats yet',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.sessions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (ctx, i) {
                        final session = state.sessions[i];
                        final isActive = session.id == state.activeSessionId;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? cs.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isActive ? Border.all(color: cs.primary.withValues(alpha: 0.5), width: 1) : null,
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              isActive ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                              color: isActive ? cs.primary : cs.onSurfaceVariant,
                              size: 18,
                            ),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                                color: isActive ? cs.primary : cs.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              session.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(Icons.more_horiz, size: 18, color: cs.onSurfaceVariant),
                              onSelected: (val) {
                                if (val == 'rename') {
                                  _showRenameDialog(session.id, session.title);
                                } else if (val == 'delete') {
                                  _confirmDeleteSession(session.id, session.title);
                                }
                              },
                              itemBuilder: (c) => [
                                const PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16),
                                      SizedBox(width: 8),
                                      Text('Rename'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              ref.read(aiCoachProvider.notifier).selectSession(session.id);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),

            const Divider(),

            // Bottom Tools
            ListTile(
              dense: true,
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
              title: const Text('Clear All Local Chats', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              onTap: _clearAllHistory,
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.settings_outlined, size: 20),
              title: const Text('AI Coach Settings (API Key)', style: TextStyle(fontSize: 13)),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state with quick starter chips
  Widget _buildEmptyState(Map<String, dynamic> summary, ColorScheme cs, bool isDark) {
    final hasActive = summary['hasActiveWorkout'] == true;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              hasActive ? 'Gym Session in Progress!' : 'What would you like to achieve?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasActive
                  ? 'Ask Coach for exercise substitutions, rest pacing, or form tips for your current lift.'
                  : 'Coach has analyzed your workout history and PRs to give you custom training advice.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickPrompt('Suggest my next workout based on recovery'),
                _buildQuickPrompt('Am I making progressive overload gains?'),
                _buildQuickPrompt('Give me a high-energy motivation boost'),
                _buildQuickPrompt('Review my top PRs and strength balance'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String prompt) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _handleSubmitted(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Text(
          prompt,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),
    );
  }

  /// Dynamic suggestions row above input bar
  Widget _buildSuggestionChips(Map<String, dynamic> summary, ColorScheme cs, bool isDark) {
    final hasActive = summary['hasActiveWorkout'] == true;
    final List<String> suggestions = hasActive
        ? [
            'Suggest an exercise swap',
            'How long should I rest?',
            'Form cue for this movement',
          ]
        : [
            'What should I train next?',
            'Analyze my recent volume',
            'How is my recovery looking?',
            'Give me pre-workout fire 🔥',
          ];

    return Container(
      height: 34,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final s = suggestions[i];
          return ActionChip(
            label: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            backgroundColor: isDark ? const Color(0xFF222222) : Colors.grey.shade200,
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () => _handleSubmitted(s),
          );
        },
      ),
    );
  }

  /// Chat Bubble with rich Markdown-like formatting (bold, bullets)
  Widget _buildChatBubble(CoachMessage message, ColorScheme cs, bool isDark) {
    final isMe = message.isUser;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10, top: 2),
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
                border: isMe
                    ? null
                    : Border.all(
                        color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildFormattedContent(message.content, isMe, cs),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      if (!isMe) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyMessage(message.content),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 36) else const SizedBox(width: 36),
        ],
      ),
    );
  }

  /// Parses **bold** and basic bullet points
  Widget _buildFormattedContent(String text, bool isMe, ColorScheme cs) {
    final baseColor = isMe ? Colors.white : cs.onSurface;
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 6);

        // Check if bullet point
        final isBullet = line.trimLeft().startsWith('•') || line.trimLeft().startsWith('-');
        final lineText = isBullet ? line.trimLeft().substring(1).trimLeft() : line;

        return Padding(
          padding: EdgeInsets.only(bottom: 2, left: isBullet ? 8 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBullet)
                Text(
                  '• ',
                  style: TextStyle(
                    color: isMe ? Colors.white : cs.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              Expanded(
                child: _buildRichInlineText(lineText, baseColor, cs),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Parses **bold** text in a line
  Widget _buildRichInlineText(String text, Color baseColor, ColorScheme cs) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(fontSize: 14.5, height: 1.4, color: baseColor),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: 14.5,
          height: 1.4,
          fontWeight: FontWeight.w800,
          color: baseColor,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(fontSize: 14.5, height: 1.4, color: baseColor),
      ));
    }

    return RichText(text: TextSpan(children: spans));
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Coach is analyzing...',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
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
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                        hintText: 'Ask Coach anything...',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: isTyping ? null : _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: isTyping
                          ? null
                          : LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                            ),
                      color: isTyping ? cs.surfaceContainerHighest : null,
                      shape: BoxShape.circle,
                      boxShadow: isTyping
                          ? []
                          : [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: isTyping ? cs.onSurfaceVariant : Colors.white, size: 19),
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
