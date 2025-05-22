import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:todo_app/models/task.dart';
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
  

  void _saveTask() {
    final String title = _titleController.text.trim();
    final String description = jsonEncode(_controller.document.toDelta().toJson());

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
    );

    TaskStorageService.addTask(task);
    Navigator.pop(context, task); // retorna a tarefa salva
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
          IconButton(
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
                            const SnackBar(content: Text('Salvo como rascunho')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: const Text('Discard'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context); // Sai da tela de adicionar task
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
          ),
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
                  setState(() {
                    _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 16),
           QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('pt', 'BR'),
                ),
                showUndo: false,
                showRedo: false,
                showSearchButton: false,
                showClipboardCopy: false,
                showClipboardCut: false,

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
                child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('pt', 'BR'),
                  ),
                ),
              ),
                // QuillEditor(
                //   controller: _controller,
                //   readOnly: false,
                //   autoFocus: true,
                //   expands: true,
                //   padding: EdgeInsets.zero,
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
