import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/therapy/data/models/chat_message.dart';
import 'package:mobile/features/therapy/presentation/providers/therapy_provider.dart';

class TherapyPage extends ConsumerStatefulWidget {
  const TherapyPage({super.key});

  @override
  ConsumerState<TherapyPage> createState() => _TherapyPageState();
}

class _TherapyPageState extends ConsumerState<TherapyPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
    final authState = ClerkAuth.of(context);
    final userId = authState.user?.id ?? '';
    final providerKey = TherapyProviderKey(userId: userId, auth: authState);

    final chatState = ref.watch(therapyProvider(providerKey));
    final notifier = ref.read(therapyProvider(providerKey).notifier);

    // Scroll bottom if new message or typing updates
    _scrollToBottom();

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: const Text('Therapy Assistant'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: () => notifier.newChat(),
            tooltip: 'New Chat',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.loadHistory(),
            tooltip: 'Sync History',
          ),
        ],
      ),
      drawer: _buildHistoryDrawer(context, chatState, notifier),
      body: Column(
        children: [
          // Status Bar
          if (chatState.status.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: AppTheme.primary(context).withOpacity(0.1),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: chatState.messages.isEmpty && !chatState.isGenerating
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _ChatMessageTile(message: message);
                    },
                  ),
          ),

          _buildInputArea(notifier, chatState.isGenerating),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(
    BuildContext context,
    ChatState state,
    TherapyNotifier notifier,
  ) {
    return Drawer(
      backgroundColor: AppTheme.background(context),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primary(context)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Chat History',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: const Text('New Chat'),
            onTap: () {
              Navigator.pop(context);
              notifier.newChat();
            },
          ),
          const Divider(),
          Expanded(
            child: state.sessions.isEmpty
                ? Center(
                    child: Text(
                      'No previous chats',
                      style: TextStyle(color: AppTheme.subText(context)),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.sessions.length,
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      final isSelected = state.currentChatId == session.id;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppTheme.primary(
                          context,
                        ).withOpacity(0.05),
                        leading: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: isSelected
                              ? AppTheme.primary(context)
                              : AppTheme.subText(context),
                        ),
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected
                                ? AppTheme.primary(context)
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          session.lastMessage ?? 'Empty chat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          notifier.switchChat(session.id);
                        },
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                          ),
                          onPressed: () {
                            _showDeleteConfirm(context, session.id, notifier);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    String chatId,
    TherapyNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this chat history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteChat(chatId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary(context).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 80,
              color: AppTheme.primary(context).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.text(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your therapy assistant is here to help you process your thoughts and emotions.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.subText(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(TherapyNotifier notifier, bool isGenerating) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isGenerating,
              style: TextStyle(color: AppTheme.text(context)),
              decoration: InputDecoration(
                hintText: isGenerating
                    ? 'AI is thinking...'
                    : 'Describe your feelings...',
                hintStyle: TextStyle(
                  color: AppTheme.subText(context).withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.background(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onSubmitted: (val) => _handleSend(notifier),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isGenerating ? null : () => _handleSend(notifier),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: isGenerating
                  ? AppTheme.subText(context).withOpacity(0.2)
                  : AppTheme.primary(context),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend(TherapyNotifier notifier) {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      _messageController.clear();
      notifier.sendMessage(text);
    }
  }
}

class _ChatMessageTile extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary(context).withOpacity(0.1),
                child: Icon(
                  Icons.psychology,
                  size: 20,
                  color: AppTheme.primary(context),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary(context)
                    : AppTheme.surface(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  if (!isUser)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content.isEmpty && message.isStreaming
                          ? '...'
                          : message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: AppTheme.text(context),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        listBullet: TextStyle(
                          color: AppTheme.primary(context),
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }
}
