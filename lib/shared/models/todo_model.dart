import 'dart:convert';

import 'package:bloc_todo/shared/enums/todo_priority.dart';

const Object _copyWithSentinel = Object();

class TodoModel {
  final int? id;
  final String? title;
  final String? description;
  final bool? isCompleted;
  final TodoPriority? priority;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final int? notificationId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.dueDate,
    required this.reminderAt,
    required this.notificationId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted == true ? 1 : 0,
      'priority': priority?.index ?? 0,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'reminderAt': reminderAt?.millisecondsSinceEpoch,
      'notificationId': notificationId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: _asInt(map['id']),
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      isCompleted: _asBool(map['isCompleted']),
      priority: _asPriority(map['priority']),
      dueDate: _asDateTime(map['dueDate']),
      reminderAt: _asDateTime(map['reminderAt']),
      notificationId: _asInt(map['notificationId']),
      createdAt: _asDateTime(map['createdAt']),
      updatedAt: _asDateTime(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) =>
      TodoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  TodoModel copyWith({
    Object? id = _copyWithSentinel,
    Object? title = _copyWithSentinel,
    Object? description = _copyWithSentinel,
    Object? isCompleted = _copyWithSentinel,
    Object? priority = _copyWithSentinel,
    Object? dueDate = _copyWithSentinel,
    Object? reminderAt = _copyWithSentinel,
    Object? notificationId = _copyWithSentinel,
    Object? createdAt = _copyWithSentinel,
    Object? updatedAt = _copyWithSentinel,
  }) {
    return TodoModel(
      id: id == _copyWithSentinel ? this.id : id as int?,
      title: title == _copyWithSentinel ? this.title : title as String?,
      description: description == _copyWithSentinel
          ? this.description
          : description as String?,
      isCompleted: isCompleted == _copyWithSentinel
          ? this.isCompleted
          : isCompleted as bool?,
      priority: priority == _copyWithSentinel
          ? this.priority
          : priority as TodoPriority?,
      dueDate: dueDate == _copyWithSentinel
          ? this.dueDate
          : dueDate as DateTime?,
      reminderAt: reminderAt == _copyWithSentinel
          ? this.reminderAt
          : reminderAt as DateTime?,
      notificationId: notificationId == _copyWithSentinel
          ? this.notificationId
          : notificationId as int?,
      createdAt: createdAt == _copyWithSentinel
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt == _copyWithSentinel
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, description: $description, isCompleted: $isCompleted, priority: $priority, dueDate: $dueDate, reminderAt: $reminderAt, notificationId: $notificationId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant TodoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.priority == priority &&
        other.dueDate == dueDate &&
        other.reminderAt == reminderAt &&
        other.notificationId == notificationId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        isCompleted.hashCode ^
        priority.hashCode ^
        dueDate.hashCode ^
        reminderAt.hashCode ^
        notificationId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _asBool(Object? value) {
  if (value is bool) return value;

  final numericValue = _asInt(value);
  if (numericValue != null) return numericValue == 1;

  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }

  return null;
}

TodoPriority? _asPriority(Object? value) {
  final index = _asInt(value);
  if (index == null || index < 0 || index >= TodoPriority.values.length) {
    return null;
  }
  return TodoPriority.values[index];
}

DateTime? _asDateTime(Object? value) {
  final milliseconds = _asInt(value);
  if (milliseconds != null) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}
