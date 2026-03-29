import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';

class EditHabitDialog extends ConsumerStatefulWidget {
  final HabitModel habit;

  const EditHabitDialog({required this.habit, super.key});

  @override
  ConsumerState<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends ConsumerState<EditHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _frequencyType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.name);
    _descriptionController = TextEditingController(
      text: widget.habit.description,
    );
    _frequencyType = widget.habit.frequency;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final request = UpdateHabitRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      frequencyType: _frequencyType,
    );

    await ref
        .read(habitsProvider.notifier)
        .updateHabit(widget.habit.id, request);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit Habit', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.edit_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _frequencyType,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                prefixIcon: Icon(Icons.repeat),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _frequencyType = value);
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
