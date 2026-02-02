import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:page_flip/page_flip.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/journal/data/models/journal_model.dart';
import 'package:mobile/features/journal/presentation/providers/journal_provider.dart';
import 'package:mobile/features/journal/presentation/widgets/ruled_paper.dart';
import 'package:mobile/features/journal/presentation/pages/journal_editor_page.dart';

class JournalBookPage extends ConsumerStatefulWidget {
  const JournalBookPage({super.key});

  @override
  ConsumerState<JournalBookPage> createState() => _JournalBookPageState();
}

class _JournalBookPageState extends ConsumerState<JournalBookPage> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final authState = ClerkAuth.of(context);
    final journalAsync = ref.watch(journalProvider(authState));

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateToEditor(context, null),
          ),
        ],
      ),
      body: journalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (journals) {
          if (journals.isEmpty) {
            return _buildEmptyState(context);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 0), // Full height alignment
            child: Stack(
              children: [
                // Underlying "Book Depth" effect
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF15151A) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                PageFlipWidget(
                  // Expert Sync: Kraft a key that changes if theme OR data changes.
                  // This forces PageFlip to drop its internal cache and show new entries.
                  key: ValueKey(
                    'page_flip_${isDark}_${journals.length}_${journals.isNotEmpty ? journals.first.updatedAt : 'empty'}',
                  ),
                  backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                  children: [
                    _buildCoverPage(context, isDark),
                    ...journals.map(
                      (entry) => _buildJournalPage(context, entry, isDark),
                    ),
                    _buildBackCoverPage(context, isDark),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context, null),
        backgroundColor: AppTheme.primary(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCoverPage(BuildContext context, bool isDark) {
    // Expert UX: Deep Charcoal for dark mode, Soft Lavender for light mode
    final coverColor = isDark
        ? const Color(0xFF1C1C21)
        : const Color(0xFFF0EFFF);
    final brandingColor = AppTheme.primary(context);

    return Container(
      color: coverColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 120,
              errorBuilder: (context, _, __) =>
                  Icon(Icons.auto_stories, size: 80, color: brandingColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Personal Journal',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                color: brandingColor.withOpacity(0.8),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalPage(
    BuildContext context,
    JournalEntry entry,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return GestureDetector(
      onLongPress: () => _showEntryActions(context, entry),
      onDoubleTap: () => _navigateToEditor(context, entry),
      child: RuledPaper(
        date: DateFormat('MMMM dd, yyyy').format(entry.createdAt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? textColor.withOpacity(0.9) : textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                entry.content,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 18,
                  height: 1.55,
                  color: isDark
                      ? textColor.withOpacity(0.7)
                      : textColor.withOpacity(0.85),
                ),
                maxLines: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCoverPage(BuildContext context, bool isDark) {
    final coverColor = isDark
        ? const Color(0xFF1C1C21)
        : const Color(0xFFF0EFFF);
    final brandingColor = AppTheme.primary(context);

    return Container(
      color: coverColor,
      child: Center(
        child: Text(
          'THE END',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 24,
            color: brandingColor,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : AppTheme.primary(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Your journal is empty.',
            style: TextStyle(color: textColor, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _navigateToEditor(context, null),
            child: const Text('Start Writing'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditor(BuildContext context, JournalEntry? entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => JournalEditorPage(entry: entry)),
    );
  }

  void _showEntryActions(BuildContext context, JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditor(context, entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Entry', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this journal entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final authState = ClerkAuth.of(context);
              ref
                  .read(journalProvider(authState).notifier)
                  .deleteEntry(entry.id!);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
