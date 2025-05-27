// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_storage_service.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({
    super.key,
    required this.task,
  });

  final Task task;
  @override
  State<EditTaskPage> createState() => _EditTaskPageState(task: task);
}

class _EditTaskPageState extends State<EditTaskPage> {
  _EditTaskPageState({required this.task});

  final Task task;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  DateTime? _dueDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = task.title;
    _dueDate = task.dueDate;
    print('Original date: $_dueDate');
    if (_dueDate != null) {
      _dateController.text = "${_dueDate!.day.toString().padLeft(2, '0')}/"
          "${_dueDate!.month.toString().padLeft(2, '0')}/"
          "${_dueDate!.year} às "
          "${_dueDate!.hour.toString().padLeft(2, '0')}:"
          "${_dueDate!.minute.toString().padLeft(2, '0')}";
      print('Formatted date: ${_dateController.text}');
    }
    _controller.document =  parseDescription(task.description);

    _dueDate = task.dueDate;
  }

  Document parseDescription(String text) {
    print('Parsing description: $text');
    try {
      final json = jsonDecode(text);
      return Document.fromJson(json);
    } catch (e) {
      print('Erro ao analisar a descrição: $e');
      // Se falhar, tentamos tratar como texto simples
      try {
        var doc = Delta()..insert(text + '\n');
        return Document.fromDelta(doc);
      } catch (e) {
        print('Erro ao criar documento de texto simples: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar a descrição')),
        );
      }
      return Document();
    }
  }

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

    setState(() {
      isLoading = true;
    });

    final editedTask = Task(
      id: task.id,
      title: title,
      description: description,
      isDone: task.isDone,
      isArchived: task.isArchived,
      dueDate: _dueDate,
    );

    try {
      await TaskStorageService.editTask(editedTask);
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa editada com sucesso')),
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isLoading
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Edit Task'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save',
                  onPressed: _saveTask,
                ),
              ],
            )
          : null,
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
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                      controller: _controller,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: LoadingAnimationWidget.newtonCradle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 50,
                ),
              ),
            )
        ],
      ),
    );
  }
}
