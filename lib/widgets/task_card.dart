import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isArchivedView;
  final bool isDeletedView;
  final VoidCallback onToggleDone;
  final void Function(String action) onAction;

  const TaskCard({
    super.key,
    required this.task,
    required this.isArchivedView,
    required this.onToggleDone,
    required this.onAction,
    required this.isDeletedView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(task.title + task.description + task.isArchived.toString()),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: isDeletedView ? null : (_) => onToggleDone(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: task.dueDate != null
              ? Text(
                  'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year} at ${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View description',
                onPressed: () {
                  try {
                    final doc = Document.fromJson(jsonDecode(task.description));
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(task.title),
                        content: SizedBox(
                          height: 300,
                          child: QuillEditor(
                            controller: QuillController(
                              document: doc,
                              selection: const TextSelection.collapsed(offset: 0),
                              readOnly: true
                            ),
                            focusNode: FocusNode(),
                            scrollController: ScrollController(),
                            ),
                          ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    // Caso a descrição não seja JSON válido
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(task.title),
                        content: Text(task.description),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: onAction,
                itemBuilder: (context) => [
                  if (task.isDeleted)
                    const PopupMenuItem(value: 'restore', child: Text('Restore')),
                  if (task.isDeleted)
                    const PopupMenuItem(value: 'delete_permanently', child: Text('Delete Permanently')),
                  if (!task.isDeleted)
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!isArchivedView && !task.isDeleted)
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  if (isArchivedView && !task.isDeleted)
                    const PopupMenuItem(value: 'unarchive', child: Text('Unarchive')),
                  if (!task.isDeleted)
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}
