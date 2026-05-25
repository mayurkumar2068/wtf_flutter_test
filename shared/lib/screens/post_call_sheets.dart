import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

void showPostCallFlow(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
  bool isTrainer,
) {
  if (isTrainer) {
    _trainerSheet(context, ref, sessionId);
  } else {
    _memberSheet(context, ref, sessionId);
  }
}

void _memberSheet(BuildContext context, WidgetRef ref, String sessionId) {
  showWtfBottomSheet(
    context: context,
    title: AppStrings.rateSession,
    subtitle: AppStrings.sessionSaved,
    children: [
      Builder(
        builder: (sheetCtx) => _MemberRatingForm(
          onSubmit: (rating, notes) async {
            await ref.read(syncClientProvider).patchSession(
                  sessionId,
                  rating: rating,
                  memberNotes: notes,
                );
            if (sheetCtx.mounted) Navigator.pop(sheetCtx);
          },
        ),
      ),
    ],
  );
}

void _trainerSheet(BuildContext context, WidgetRef ref, String sessionId) {
  final notesController = TextEditingController();
  showWtfBottomSheet(
    context: context,
    title: 'Session notes',
    subtitle: AppStrings.markComplete,
    children: [
      TextField(
        controller: notesController,
        decoration: const InputDecoration(
          labelText: 'Quick notes',
          hintText: 'Key points from the call…',
        ),
        maxLines: 3,
      ),
      const SizedBox(height: 16),
      Builder(
        builder: (sheetCtx) => WtfButton(
          label: AppStrings.markComplete,
          icon: Icons.check_circle_outline_rounded,
          onPressed: () async {
            await ref.read(syncClientProvider).patchSession(
                  sessionId,
                  trainerNotes: notesController.text.isEmpty
                      ? 'Marked as complete'
                      : notesController.text,
                );
            if (sheetCtx.mounted) Navigator.pop(sheetCtx);
          },
        ),
      ),
    ],
  );
}

class _MemberRatingForm extends StatefulWidget {
  const _MemberRatingForm({required this.onSubmit});

  final Future<void> Function(int rating, String? notes) onSubmit;

  @override
  State<_MemberRatingForm> createState() => _MemberRatingFormState();
}

class _MemberRatingFormState extends State<_MemberRatingForm> {
  int _rating = 5;
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.warning,
                size: 36,
              ),
              onPressed: () => setState(() => _rating = i + 1),
            );
          }),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          decoration: const InputDecoration(
            labelText: 'Optional note',
            hintText: 'How was your session?',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        WtfButton(
          label: 'Submit feedback',
          loading: _saving,
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  await widget.onSubmit(
                    _rating,
                    _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                  );
                },
        ),
      ],
    );
  }
}
