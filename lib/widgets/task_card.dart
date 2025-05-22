import 'package:flutter/material.dart';
import '../models/task.dart';

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
          subtitle: Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: PopupMenuButton<String>(
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
        ),
      ),
    );
  }
}
