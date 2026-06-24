import 'package:bloc_todo/app/di/injection.dart';
import 'package:bloc_todo/core/services/notification_service.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:bloc_todo/core/utils/app_logger.dart';
import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/shared/enums/todo_priority.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTodoPage extends StatefulWidget {
  const EditTodoPage({super.key, required this.todoId});

  final int todoId;

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final TodoRepository _repository;
  late final NotificationService _notificationService;
  late Future<TodoModel?> _todoFuture;

  TodoModel? _todo;
  TodoPriority _priority = TodoPriority.medium;
  DateTime? _dueDate;
  DateTime? _reminderAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _repository = Injection.getIt<TodoRepository>();
    _notificationService = Injection.getIt<NotificationService>();
    _todoFuture = _loadTodo();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<TodoModel?> _loadTodo() async {
    final todo = await _repository.getTodoById(widget.todoId);
    if (todo == null) return null;

    _todo = todo;
    _titleController.text = todo.title ?? '';
    _descriptionController.text = todo.description ?? '';
    _priority = todo.priority ?? TodoPriority.medium;
    _dueDate = todo.dueDate ?? _today();
    _reminderAt = todo.reminderAt;

    return todo;
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;

    final todo = _todo;
    final dueDate = _dueDate;
    if (todo == null || dueDate == null) return;

    setState(() => _isSaving = true);

    final previousNotificationId = todo.notificationId;
    final previousReminderAt = todo.reminderAt;
    final notificationId = todo.id ?? widget.todoId;
    final description = _descriptionController.text.trim();
    var updatedTodo = todo.copyWith(
      title: _titleController.text.trim(),
      description: description.isEmpty ? null : description,
      priority: _priority,
      dueDate: dueDate,
      reminderAt: _reminderAt,
      notificationId: _reminderAt == null ? null : notificationId,
      updatedAt: DateTime.now(),
    );

    String? warningMessage;

    try {
      if (previousNotificationId != null && previousReminderAt != _reminderAt) {
        await _notificationService.cancelNotification(previousNotificationId);
      }

      if (_reminderAt != null && previousReminderAt != _reminderAt) {
        await _notificationService.scheduleTodoReminder(
          id: notificationId,
          title: updatedTodo.title ?? 'Todo reminder',
          body: updatedTodo.description ?? 'Your task is due soon',
          scheduledAt: _reminderAt!,
          payload: 'todo_detail:${updatedTodo.id}',
        );
      }
    } catch (error, stackTrace) {
      warningMessage = 'Todo updated, but the reminder was not scheduled.';
      updatedTodo = updatedTodo.copyWith(notificationId: null);
      AppLogger.e(
        'Failed to update todo reminder',
        error: error,
        stackTrace: stackTrace,
        data: {'todoId': updatedTodo.id},
      );
    }

    try {
      await _repository.updateTodo(updatedTodo);

      if (!mounted) return;

      Navigator.of(context).pop(updatedTodo);

      if (warningMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(warningMessage)));
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Could not update todo: $error')),
        );
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final today = _today();
    final initialDate = (_dueDate ?? today).isBefore(today)
        ? today
        : _dueDate ?? today;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 10, 12, 31),
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _dueDate = selectedDate;
      if (_reminderAt != null && _reminderAt!.isAfter(_endOfDueDate())) {
        _reminderAt = null;
      }
    });
  }

  Future<void> _pickReminder() async {
    final dueDate = _dueDate;
    if (dueDate == null) return;

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
        reminderAt = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
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

  Future<DateTime?> _pickCustomReminder() async {
    final dueDate = _dueDate;
    if (dueDate == null) return null;

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: dueDate.isBefore(_today()) ? _today() : dueDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: dueDate,
    );

    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _dueDateAtNine() {
    final dueDate = _dueDate ?? _today();
    return DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
  }

  DateTime _endOfDueDate() {
    final dueDate = _dueDate ?? _today();
    return DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59, 999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<TodoModel?>(
          future: _todoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null) {
              return const _EditMessage();
            }

            return Form(
              key: _formKey,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _EditHeader(isSaving: _isSaving),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _EditForm(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        priority: _priority,
                        dueDate: _dueDate ?? _today(),
                        reminderAt: _reminderAt,
                        enabled: !_isSaving,
                        onPriorityChanged: (priority) {
                          setState(() => _priority = priority);
                        },
                        onDueDateTap: _pickDueDate,
                        onReminderTap: _pickReminder,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 58,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.surface,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditHeader extends StatelessWidget {
  const _EditHeader({required this.isSaving});

  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Todo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Update task details',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
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
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BottomSheetHandle(),
          SizedBox(height: 22),
          Text(
            'Set reminder',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Choose when you want to be reminded.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20),
          _ReminderOptionTile(
            option: _ReminderOption.atDueTime,
            icon: Icons.alarm_rounded,
            title: 'On due date',
            subtitle: 'At 9:00 AM',
          ),
          _ReminderOptionTile(
            option: _ReminderOption.tenMinutesBefore,
            icon: Icons.schedule_rounded,
            title: '10 minutes before',
          ),
          _ReminderOptionTile(
            option: _ReminderOption.oneHourBefore,
            icon: Icons.schedule_rounded,
            title: '1 hour before',
          ),
          _ReminderOptionTile(
            option: _ReminderOption.oneDayBefore,
            icon: Icons.calendar_today_outlined,
            title: '1 day before',
          ),
          Divider(height: 24, color: AppColors.border),
          _ReminderOptionTile(
            option: _ReminderOption.custom,
            icon: Icons.tune_rounded,
            title: 'Custom date and time',
            trailingIcon: Icons.chevron_right_rounded,
          ),
          _ReminderOptionTile(
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

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.dragHandle,
          borderRadius: BorderRadius.circular(2),
        ),
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

class _EditMessage extends StatelessWidget {
  const _EditMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 54,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 18),
          const Text(
            'Todo not found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
