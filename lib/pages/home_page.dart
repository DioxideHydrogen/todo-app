import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/add_task_page.dart';
import 'package:todo_app/services/task_storage_service.dart';
import 'package:todo_app/widgets/task_card.dart';
import 'package:todo_app/services/notification_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks = [];

  @override
  void initState(){
    super.initState();
    loadTasks();
  }

  void _addTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    );

    if (result != null) {
      setState(() {
        tasks.add(result);
      });
      saveTasks(); // salva no storage local
    }
    /*
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a new task:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.trim().isNotEmpty) {
                  setState(() {
                    tasks.add(Task(
                        title: title.trim(), description: description.trim()));
                    saveTasks();
                  });
                  Navigator.pop(context); // fecha o popup
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    */
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
      length: 2,
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
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(showArchived: false),
            _buildTaskList(showArchived: true),
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

  Widget _buildTaskList({required bool showArchived}) {
    final filteredTasks =
        tasks.where((t) => t.isArchived == showArchived).toList();

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
              onToggleDone: () {
                setState(() {
                  task.isDone = !task.isDone;
                  saveTasks();
                });
              },
              onAction: (value) {
                setState(() {
                  if (value == 'archive') {
                    task.isArchived = true;
                  } else if (value == 'unarchive') {
                    task.isArchived = false;
                  } else if (value == 'delete') {
                    tasks.remove(task);
                  }
                  saveTasks();
                });
              },
            ),
        );
      },
    );
  }

  void saveTasks() => TaskStorageService.saveTasks(tasks);
  Future<void> loadTasks() async {
    tasks = await TaskStorageService.loadTasks();
    setState(() {});
  }
}
