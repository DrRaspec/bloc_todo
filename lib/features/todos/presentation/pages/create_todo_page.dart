import 'package:bloc_todo/features/todos/presentation/cubit/create_todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/create_todo_state.dart';
import 'package:bloc_todo/shared/enums/todo_priority.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateTodoPage extends StatefulWidget {
  const CreateTodoPage({super.key});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TodoPriority _priority = TodoPriority.medium;
  late DateTime _dueDate;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dueDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now();
    final description = _descriptionController.text.trim();

    context.read<CreateTodoCubit>().createTodo(
      TodoModel(
        id: null,
        title: _titleController.text.trim(),
        description: description.isEmpty ? null : description,
        isCompleted: false,
        priority: _priority,
        dueDate: _dueDate,
        reminderAt: _reminderAt,
        notificationId: null,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTodoCubit, CreateTodoState>(
      listener: (context, state) {
        if (state.status == CreateTodoStatus.success) {
          final warningMessage = state.warningMessage;
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          Navigator.of(context).pop(state.createdTodo);

          if (warningMessage != null) {
            scaffoldMessenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(warningMessage)));
          }
        }

        if (state.status == CreateTodoStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Could not create todo'),
              ),
            );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == CreateTodoStatus.submitting;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _CreateTodoHeader(isSubmitting: isSubmitting),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _TodoFormCard(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        priority: _priority,
                        dueDate: _dueDate,
                        reminderAt: _reminderAt,
                        enabled: !isSubmitting,
                        onPriorityChanged: (priority) {
                          setState(() => _priority = priority);
                        },
                        onDueDateTap: _pickDueDate,
                        onReminderTap: _showReminderOptions,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    sliver: SliverToBoxAdapter(
                      child: _SaveButton(
                        isSubmitting: isSubmitting,
                        onPressed: _submit,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
      firstDate: today,
      lastDate: DateTime(now.year + 10, 12, 31),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dueDate = selectedDate;

        if (_reminderAt != null && _reminderAt!.isAfter(_endOfDueDate())) {
          _reminderAt = null;
        }
      });
    }
  }

  Future<void> _showReminderOptions() async {
    final option = await showModalBottomSheet<_ReminderOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ReminderBottomSheet(),
    );

    if (option == null) return;

    DateTime? reminderAt;

    switch (option) {
      case _ReminderOption.none:
        reminderAt = null;

      case _ReminderOption.atDueTime:
        reminderAt = DateTime(_dueDate.year, _dueDate.month, _dueDate.day, 9);

      case _ReminderOption.tenMinutesBefore:
        reminderAt = _dueDateAtNine().subtract(const Duration(minutes: 10));

      case _ReminderOption.oneHourBefore:
        reminderAt = _dueDateAtNine().subtract(const Duration(hours: 1));

      case _ReminderOption.oneDayBefore:
        reminderAt = _dueDateAtNine().subtract(const Duration(days: 1));

      case _ReminderOption.custom:
        reminderAt = await _pickCustomReminder();
    }

    if (reminderAt != null && !reminderAt.isAfter(DateTime.now())) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder must be in the future')),
      );
      return;
    }

    setState(() => _reminderAt = reminderAt);
  }

  DateTime _dueDateAtNine() {
    return DateTime(_dueDate.year, _dueDate.month, _dueDate.day, 9);
  }

  DateTime _endOfDueDate() {
    return DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      23,
      59,
      59,
      999,
    );
  }

  Future<DateTime?> _pickCustomReminder() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: _dueDate,
    );

    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _CreateTodoHeader extends StatelessWidget {
  const _CreateTodoHeader({required this.isSubmitting});

  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Todo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add a new task to your list',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodoFormCard extends StatelessWidget {
  const _TodoFormCard({
    required this.titleController,
    required this.descriptionController,
    required this.priority,
    required this.dueDate,
    required this.reminderAt,
    required this.enabled,
    required this.onPriorityChanged,
    required this.onDueDateTap,
    required this.onReminderTap,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TodoPriority priority;
  final DateTime dueDate;
  final DateTime? reminderAt;
  final bool enabled;
  final ValueChanged<TodoPriority> onPriorityChanged;
  final VoidCallback onDueDateTap;
  final VoidCallback onReminderTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Task title'),
        const SizedBox(height: 10),
        _InputField(
          controller: titleController,
          hintText: 'Example: Learn Bloc',
          maxLines: 1,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a task title';
            }
            return null;
          },
        ),
        const SizedBox(height: 22),
        const _FieldLabel('Description'),
        const SizedBox(height: 10),
        _InputField(
          controller: descriptionController,
          hintText: 'Write a short note...',
          maxLines: 4,
          enabled: enabled,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 22),
        const _FieldLabel('Priority'),
        const SizedBox(height: 12),
        _PrioritySelector(
          priority: priority,
          enabled: enabled,
          onChanged: onPriorityChanged,
        ),
        const SizedBox(height: 22),
        const _FieldLabel('Due date'),
        const SizedBox(height: 10),
        _OptionTile(
          icon: Icons.calendar_today_outlined,
          title: MaterialLocalizations.of(context).formatMediumDate(dueDate),
          subtitle: 'Tap to choose another date',
          onTap: enabled ? onDueDateTap : null,
        ),
        const SizedBox(height: 14),
        _OptionTile(
          icon: Icons.notifications_none_rounded,
          title: 'Reminder',
          subtitle: reminderAt == null
              ? 'No reminder'
              : DateFormat('dd/MM/yyyy HH:mm').format(reminderAt!),
          onTap: enabled ? onReminderTap : null,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    required this.enabled,
    required this.textInputAction,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool enabled;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.priority,
    required this.enabled,
    required this.onChanged,
  });

  final TodoPriority priority;
  final bool enabled;
  final ValueChanged<TodoPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: TodoPriority.values.map((item) {
        return ChoiceChip(
          label: Text(_priorityLabel(item)),
          selected: priority == item,
          onSelected: enabled ? (_) => onChanged(item) : null,
          showCheckmark: false,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.background,
          labelStyle: TextStyle(
            color: priority == item
                ? AppColors.surface
                : AppColors.primaryDisabled,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        );
      }).toList(),
    );
  }

  String _priorityLabel(TodoPriority priority) {
    final name = priority.name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ReminderOption {
  none,
  atDueTime,
  tenMinutesBefore,
  oneHourBefore,
  oneDayBefore,
  custom,
}

class _ReminderBottomSheet extends StatelessWidget {
  const _ReminderBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dragHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Set reminder',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose when you want to be reminded.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const _ReminderOptionTile(
            option: _ReminderOption.atDueTime,
            icon: Icons.alarm_rounded,
            title: 'On due date',
            subtitle: 'At 9:00 AM',
          ),
          const _ReminderOptionTile(
            option: _ReminderOption.tenMinutesBefore,
            icon: Icons.schedule_rounded,
            title: '10 minutes before',
          ),
          const _ReminderOptionTile(
            option: _ReminderOption.oneHourBefore,
            icon: Icons.schedule_rounded,
            title: '1 hour before',
          ),
          const _ReminderOptionTile(
            option: _ReminderOption.oneDayBefore,
            icon: Icons.calendar_today_outlined,
            title: '1 day before',
          ),
          const Divider(height: 24, color: AppColors.border),
          const _ReminderOptionTile(
            option: _ReminderOption.custom,
            icon: Icons.tune_rounded,
            title: 'Custom date and time',
            trailingIcon: Icons.chevron_right_rounded,
          ),
          const _ReminderOptionTile(
            option: _ReminderOption.none,
            icon: Icons.notifications_off_outlined,
            title: 'No reminder',
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _ReminderOptionTile extends StatelessWidget {
  const _ReminderOptionTile({
    required this.option,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.isDestructive = false,
  });

  final _ReminderOption option;
  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData? trailingIcon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDestructive
        ? AppColors.danger
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, option),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.dangerBackground
                      : AppColors.subtleFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: foregroundColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSubmitting, required this.onPressed});

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryDisabled,
          foregroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.surface,
                ),
              )
            : const Text(
                'Create Task',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
