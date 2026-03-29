import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_model.dart';
import 'package:habitpal_frontend/features/habits/domain/habit_provider.dart';
import 'package:habitpal_frontend/shared/utils/habit_icons.dart';

class CreateHabitDialog extends ConsumerStatefulWidget {
  const CreateHabitDialog({super.key});

  @override
  ConsumerState<CreateHabitDialog> createState() => _CreateHabitDialogState();
}

class _CreateHabitDialogState extends ConsumerState<CreateHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _frequencyType = 'daily';
  String _selectedIcon = '';
  String _selectedColor = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final request = CreateHabitRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      frequencyType: _frequencyType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    await ref.read(habitsProvider.notifier).createHabit(request);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Habit', style: theme.textTheme.titleLarge),
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
              const SizedBox(height: 16),
              // Color picker
              Text('Color', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _ColorPicker(
                selectedHex: _selectedColor,
                onColorSelected: (hex) {
                  setState(() => _selectedColor = hex);
                },
              ),
              const SizedBox(height: 16),
              // Icon picker
              Text('Icon', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _IconPicker(
                selectedIcon: _selectedIcon,
                selectedColorHex: _selectedColor,
                onIconSelected: (name) {
                  setState(() => _selectedIcon = name);
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
                        : const Text('Create Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onColorSelected;

  const _ColorPicker({
    required this.selectedHex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          habitColorOptions.map((option) {
            final isSelected = selectedHex == option.hex;
            return GestureDetector(
              onTap: () => onColorSelected(isSelected ? '' : option.hex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                          : null,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: option.color.withAlpha(100),
                              blurRadius: 6,
                            ),
                          ]
                          : null,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}

class _IconPicker extends StatelessWidget {
  final String selectedIcon;
  final String selectedColorHex;
  final ValueChanged<String> onIconSelected;

  const _IconPicker({
    required this.selectedIcon,
    required this.selectedColorHex,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = parseHabitColor(
      selectedColorHex,
      theme.colorScheme.primary,
    );

    // Exclude the 'default' key from the picker
    final pickableIcons =
        habitIconMap.entries.where((e) => e.key != 'default').toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          pickableIcons.map((entry) {
            final isSelected = selectedIcon == entry.key;
            return GestureDetector(
              onTap: () => onIconSelected(isSelected ? '' : entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? accentColor.withAlpha(30)
                          : theme.colorScheme.surfaceContainerHighest.withAlpha(
                            120,
                          ),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      isSelected
                          ? Border.all(color: accentColor, width: 2)
                          : null,
                ),
                child: Icon(
                  entry.value,
                  size: 22,
                  color: isSelected ? accentColor : theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
    );
  }
}
