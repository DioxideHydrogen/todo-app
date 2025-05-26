// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/add_task_page.dart';
import 'package:todo_app/pages/edit_task_page.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/services/task_storage_service.dart';
import 'package:todo_app/widgets/task_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.token});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String token;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  List<Task> tasks = [];
  List<Task> deletedTasks = [];

  String token = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    if (token.isNotEmpty) print('Token passado com sucesso para o widget: $token');
    _loadTasksFromApi();
    _loadDeletedTasksFromApi();
  }

  Future<List<Task>> _loadTasksFromApi() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedTasks = await loadTasks();
      tasks = loadedTasks;
      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
      return tasks;
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      setState(() {
        isLoading = false;
      });
      throw Exception('Erro ao carregar tarefas: $e');
    }
  }

  Future<List<Task>> _loadDeletedTasksFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Token não encontrado');

      final response = await TaskStorageService.loadDeletedTasks();
      deletedTasks = response.map((e) => Task.fromJsonApi(e)).toList();
      return deletedTasks;
    } catch (e) {
      print('Erro ao carregar tarefas deletadas: $e');
      throw Exception('Erro ao carregar tarefas deletadas: $e');
    }
  }

  void _addTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );

    if (result != null) {
      print('Tarefa adicionada: ${result.title}');
      print('Recarregando tarefas após adicionar uma nova tarefa');
      var realoadedTasks = await _loadTasksFromApi();
      print('Tarefas recarregadas: ${realoadedTasks.length}');
      setState(() {
        tasks = realoadedTasks;
      });
    }
  }

  Future<void> _restoreDeletedTask(Task task) async {
    try {
      setState(() {
        isLoading = true;
      });
      await TaskStorageService.restoreTask(task.id!);
      await _loadDeletedTasksFromApi();
      await _loadTasksFromApi();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarefa "${task.title}" restaurada com sucesso')),
      );
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao restaurar tarefa: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao restaurar tarefa')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline),
              SizedBox(width: 8),
              Text('Sweet List'),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Archiveds'),
              Tab(text: 'Deleteds'),
            ],
          ),
        ),
        body: isLoading
        ? Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          )
        : TabBarView(
          children: [
            _buildTaskList(showArchived: false),
            _buildTaskList(showArchived: true),
            _buildTaskList(showArchived: false, showDeleted: true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTask,
          tooltip: 'Add Task',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList({required bool showArchived, bool showDeleted = false}) {
    var filteredTasks =
        tasks.where((t) => t.isArchived == showArchived).toList();

    if (showDeleted) {
      filteredTasks = deletedTasks;
    } else {
      filteredTasks.removeWhere((t) => t.isDeleted);
    }

    if (filteredTasks.isEmpty) {
      return const Center(child: Text('No tasks here.'));
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: TaskCard(
            task: task,
            isArchivedView: showArchived,
            onToggleDone: () async {
              task.isDone = !task.isDone;
              if (task.id != null) {
                task.isDone
                    ? await ApiService.completeTask(task.id!, token)
                    : await ApiService.uncompleteTask(task.id!, token);
              }

              setState(() {
                task.isDone = task.isDone;
              });
            },
            onAction: (value) async {
              if (value == 'archive') {
                setState(() {
                  isLoading = true;
                });
                await ApiService.archiveTask(task.id!, token);
                setState(() {
                  isLoading = false;
                });
              } else if (value == 'unarchive') {
                setState(() {
                  isLoading = true;
                });
                await ApiService.unarchiveTask(task.id!, token);
                setState(() {
                  isLoading = false;
                });
              } else if (value == 'delete') {
                setState(() {
                  isLoading = true;
                });
                tasks.remove(task);
                await ApiService.deleteTask(task.id!, token);
                await _loadDeletedTasksFromApi();
                setState(() {
                  isLoading = false;
                });
              } else if(value == 'edit') {
                final result = await Navigator.push<Task>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTaskPage(task: task),
                  ),
                );

                if (result != null) {
                  setState(() {
                    isLoading = true;
                  });
                  await _loadTasksFromApi();
                  await _loadDeletedTasksFromApi();
                  setState(() {
                    isLoading = false;
                  });
                }
              } else if (value == 'restore') {
                setState(() {
                  isLoading = true;
                });
                await _restoreDeletedTask(task);
                setState(() {
                  isLoading = false;
                });
              }

              setState(() {
                if (value == 'archive') {
                  task.isArchived = true;
                } else if (value == 'unarchive') {
                  task.isArchived = false;
                } else if (value == 'delete') {
                  tasks.remove(task);
                } else if (value == 'restore') {
                  task.isDeleted = false;
                }
              });
            },
          ),
        );
      },
    );
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');

    final response = await ApiService.getTasks(token);
    return response.map((e) => Task.fromJsonApi(e)).toList();
  }
}
