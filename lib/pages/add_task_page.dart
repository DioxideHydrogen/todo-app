import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
   final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  DateTime? _dueDate;
  bool isLoading = false;

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

    if (_controller.document.isEmpty()) {
      // Verifica se o conteúdo do editor está vazio
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descrição é obrigatória')),
      );
      return;
    }

    var task = Task(
      title: title,
      description: description,
      isDone: false,
      isArchived: false,
      dueDate: _dueDate,
    );

    try {
      setState(() {
        isLoading = true;
      });
      task = await TaskStorageService.addTask(task);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar a tarefa.')),
      );
      return;
    }

    if (_dueDate != null) {
      try {
        await NotificationService.scheduleTaskNotifications(
          idBase: task.uniqueId!,
          title: title,
          date: _dueDate!,
        );
      } catch (e) {
        print('Erro ao agendar notificação: $e');
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

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !isLoading ? 
        AppBar(
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
          ],
        ):
        null
        ,
        body: Stack(
          children: [
            Padding(
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
                                  content:
                                      Text('A data e hora devem ser futuras.')),
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
                  QuillSimpleToolbar(
                    controller: _controller,
                    config: const QuillSimpleToolbarConfig(
                      showBoldButton: true,
                      showItalicButton: true,
                      showUndo: false,
                      showRedo: false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QuillEditor(
                        controller: _controller,
                        focusNode: _editorFocusNode,
                        scrollController: _editorScrollController,
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: LoadingAnimationWidget.newtonCradle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 50,
                ),
              ),
            )
          ],
        ));
  }

}
