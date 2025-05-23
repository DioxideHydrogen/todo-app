import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isArchivedView;
  final VoidCallback onToggleDone;
  final void Function(String action) onAction;

  const TaskCard({
    super.key,
    required this.task,
    required this.isArchivedView,
    required this.onToggleDone,
    required this.onAction,
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
            onChanged: isArchivedView ? null : (_) => onToggleDone(),
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
                    final doc = quill.Document.fromJson(jsonDecode(task.description));
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(task.title),
                        content: SizedBox(
                          height: 300,
                          child: quill.QuillEditor.basic(
                            configurations: quill.QuillEditorConfigurations(
                              controller: quill.QuillController(
                                document: doc,
                                selection: const TextSelection.collapsed(offset: 0),
                              ),
                              scrollable: true,
                              padding: const EdgeInsets.all(8),
                              enableInteractiveSelection: false,
                              showCursor: false,
                              enableSelectionToolbar: false,
                            ),
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
                  if (!isArchivedView)
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  if (isArchivedView)
                    const PopupMenuItem(value: 'unarchive', child: Text('Unarchive')),
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
