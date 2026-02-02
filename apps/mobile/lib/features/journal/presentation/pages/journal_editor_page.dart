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
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JournalEditorPage extends ConsumerStatefulWidget {
  final JournalEntry? entry;

  const JournalEditorPage({super.key, this.entry});

  @override
  ConsumerState<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends ConsumerState<JournalEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Voice Typing State
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
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
    _speech.stop();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      // Check permissions first
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Microphone permission denied.')),
            );
          }
          return;
        }
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          print('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          print('STT Error: $errorNotification');
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${errorNotification.errorMsg}')),
            );
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                // We append the new transcription to whatever was there
                if (result.finalResult) {
                  final newText = result.recognizedWords;
                  if (newText.isNotEmpty) {
                    final currentText = _contentController.text;
                    _contentController.text = currentText.isEmpty
                        ? newText
                        : '$currentText $newText';

                    // Move cursor to end
                    _contentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _contentController.text.length),
                    );
                  }
                  _isListening = false;
                }
              });
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: _isListening ? Colors.red : AppTheme.text(context),
                ),
                onPressed: _toggleListening,
              )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                autoPlay: _isListening,
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 600.ms,
                curve: Curves.easeInOut,
              )
              .shimmer(
                duration: 1.5.seconds,
                color: Colors.red.withOpacity(0.2),
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
