import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/notification_service.dart';
import 'dart:convert';

import 'package:todo_app/services/task_storage_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  DateTime? _dueDate;

  void _saveTask() async {
    final String title = _titleController.text.trim();
    final String description =
        jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título é obrigatório')),
      );
      return;
    }

    final task = Task(
      title: title,
      description: description,
      isDone: false,
      isArchived: false,
      dueDate: _dueDate,
    );

    TaskStorageService.addTask(task);

    if (_dueDate != null) {
      try {
        await NotificationService.scheduleTaskNotifications(
          idBase: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title,
          date: _dueDate!,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Erro ao agendar notificação. Permissão pode estar bloqueada.',
            ),
            action: SnackBarAction(
              label: 'Abrir Configurações',
              onPressed: () {
                // Abrir configurações de notificações do app
                NotificationService.requestPermission();
              },
            ),
          ),
        );
      }
    }

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Task'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _saveTask,
          ),
          false
              ? IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More',
                  onPressed: () {
                    // Show floating action menu
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.save_alt),
                              title: const Text('Draft'),
                              onTap: () {
                                // Salvar como rascunho (draft)
                                // Exemplo: TaskStorageService.saveDraft(...)
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Salvo como rascunho')),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete_outline),
                              title: const Text('Discard'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(
                                    context); // Sai da tela de adicionar task
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Descartado')),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final fullDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    if (fullDateTime.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('A data e hora devem ser futuras.')),
                      );
                      return;
                    }

                    setState(() {
                      _dueDate = fullDateTime;
                      _dateController.text =
                          "${_dueDate!.day.toString().padLeft(2, '0')}/"
                          "${_dueDate!.month.toString().padLeft(2, '0')}/"
                          "${_dueDate!.year} às "
                          "${_dueDate!.hour.toString().padLeft(2, '0')}:"
                          "${_dueDate!.minute.toString().padLeft(2, '0')}";
                    });
                  }
                }
              },
            ),
            QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(controller: _controller),
            ),
            const SizedBox(height: 16),
           Expanded(
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(controller: _controller),
              ),
            )
          ],
        ),
      ),
    );
  }
}
