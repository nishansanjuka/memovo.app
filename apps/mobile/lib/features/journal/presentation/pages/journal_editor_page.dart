import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/journal/data/models/journal_model.dart';
import 'package:mobile/features/journal/presentation/providers/journal_provider.dart';
import 'package:mobile/features/journal/presentation/widgets/ruled_paper.dart';

class JournalEditorPage extends ConsumerStatefulWidget {
  final JournalEntry? entry;

  const JournalEditorPage({super.key, this.entry});

  @override
  ConsumerState<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends ConsumerState<JournalEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first!')),
      );
      return;
    }

    final authState = ClerkAuth.of(context);
    final notifier = ref.read(journalProvider(authState).notifier);

    if (widget.entry != null) {
      await notifier.updateEntry(
        widget.entry!.copyWith(
          title: _titleController.text.isEmpty
              ? 'Untitled'
              : _titleController.text,
          content: _contentController.text,
          mood: null,
        ),
      );
    } else {
      await notifier.addEntry(
        _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        _contentController.text,
        mood: null,
      );
    }

    // Expert Sync: Invalidate the provider to ensure the book refetches
    // the absolute latest data from the backend.
    ref.invalidate(journalProvider(authState));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force rebuild on theme change
    ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
      appBar: AppBar(
        title: Text(widget.entry != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _save,
          ),
          const Gap(8),
        ],
      ),
      body: SafeArea(
        child: RuledPaper(
          date: DateFormat(
            'MMMM dd, yyyy',
          ).format(widget.entry?.createdAt ?? DateTime.now()),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Entry Title',
                  hintStyle: TextStyle(fontFamily: 'Serif', color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text(context).withOpacity(0.9),
                ),
              ),
              const Gap(16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Start writing your memories...',
                    hintStyle: TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 20,
                    height: 1.4,
                    color: AppTheme.text(context).withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildToolbar(),
    );
  }

  Widget _buildToolbar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice typing coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () {},
          ),
          const Spacer(),
          // Small discreet save button in toolbar as expert UX choice
          IconButton(
            onPressed: _save,
            icon: Icon(Icons.save_outlined, color: AppTheme.primary(context)),
          ),
        ],
      ),
    );
  }
}
