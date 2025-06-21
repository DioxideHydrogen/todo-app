import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/edit_task_page.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/services/task_storage_service.dart';
import 'package:todo_app/widgets/task_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? selectedDay;

  void _onDaySelected(DateTime day) {
    setState(() {
      selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: CalendarWidget(
                  onDaySelected:
                      _onDaySelected, // Passa a função de seleção de dia
                  selectedDay: selectedDay, // Passa o dia selecionado
                ),
              )),
          const SizedBox(height: 20),
          TaksListWidget(
            selectedDay: selectedDay, // Passa o dia selecionado para a lista
          ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  final Function(DateTime selectedDay) onDaySelected;
  final DateTime? selectedDay;

  const CalendarWidget(
      {super.key, required this.onDaySelected, this.selectedDay});

  DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime focusedDay;
  DateTime firstDay = DateTime.utc(2010, 10, 16);
  DateTime lastDay = DateTime.utc(2030, 3, 14);
  CalendarFormat calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<Task>> taskEvents = {};

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Map<DateTime, List<Task>> normalizeAndGroupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> events = {};

    for (final task in tasks) {
      if (task.createdAt == null) continue;

      final normalizedDate = DateTime(
        task.createdAt!.year,
        task.createdAt!.month,
        task.createdAt!.day,
      );

      if (events.containsKey(normalizedDate)) {
        events[normalizedDate]!.add(task);
      } else {
        events[normalizedDate] = [task];
      }
    }

    return events;
  }

  Future<Map<DateTime, List<Task>>> generateTaskEventsMap() async {
    try {
      final rawTasks = await TaskStorageService.loadTasks();
      final taskList = rawTasks.map((e) => Task.fromJsonApi(e)).toList();

      return normalizeAndGroupTasksByDate(taskList);
    } catch (e) {
      print('Erro ao gerar eventos das tarefas: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    focusedDay = widget.getToday();
    print("Dia atual: ${DateTime.now().add(const Duration(days: 1))}");
    Future.microtask(() async {
      final events = await generateTaskEventsMap();
      setState(() {
        // Atualiza o estado para refletir as tarefas carregadas
        taskEvents = events;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: firstDay,
      lastDay: lastDay,
      calendarFormat: calendarFormat,
      locale: Localizations.localeOf(context).toString(),
      daysOfWeekHeight: 30,
      selectedDayPredicate: (day) => isSameDay(day, focusedDay),
      onPageChanged: (focusedDay) {
        setState(() {
          this.focusedDay = focusedDay;
        });
      },
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return taskEvents[normalizedDay] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, tasks) {
          if (tasks.isEmpty) return const SizedBox();
          return Positioned(
            bottom: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tasks.length > 3 ? 3 : tasks.length,
                (index) => Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          this.focusedDay = focusedDay;
        });
        widget.onDaySelected(_normalizeDate(selectedDay));
        // Aqui você pode adicionar lógica para lidar com a seleção de um dia
        print('Dia selecionado: $selectedDay');
      },
      onFormatChanged: (format) => setState(() {
        print('Formato do calendário alterado: $format');
        calendarFormat = format;
      }),
    );
  }
}

class TaksListWidget extends StatefulWidget {
  final DateTime? selectedDay;

  const TaksListWidget({super.key, required this.selectedDay});

  @override
  State<TaksListWidget> createState() => _TaksListWidgetState();
}

class _TaksListWidgetState extends State<TaksListWidget> {
  bool isLoading = false;
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  String token = '';

  void _loadTasks() async {
    // Simula um carregamento de tarefas
    setState(() {
      isLoading = true; // Inicia o carregamento
    });

    // Obtém o token do usuário
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    if (token.isEmpty) {
      print('Token não encontrado. Verifique se o usuário está autenticado.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      setState(() {
        isLoading = false; // Finaliza o carregamento
      });
      return;
    }

    final response = await TaskStorageService.loadTasks();
    final tasks = response.map((e) => Task.fromJsonApi(e));
    final filteredTasks = widget.selectedDay == null
        ? <Task>[]
        : tasks.where((task) {
            return task.createdAt != null &&
                task.createdAt!.year == widget.selectedDay!.year &&
                task.createdAt!.month == widget.selectedDay!.month &&
                task.createdAt!.day == widget.selectedDay!.day;
          }).toList();
    print('Tarefas carregadas: ${tasks.length}');
    setState(() {
      isLoading = false; // Finaliza o carregamento
      this.filteredTasks = filteredTasks.toList();
      this.token = token; // Armazena o token para uso posterior
      this.tasks = tasks.toList();
    });
  }

  // response.map((e) => Task.fromJsonApi(e)).toList();
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTasks());
  }

  @override
  void didUpdateWidget(covariant TaksListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay &&
        widget.selectedDay != null) {
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedDay == null) {
      return const Center(child: Text('Nenhum dia selecionado'));
    }

    if (isLoading) {
      // Aqui você pode exibir um indicador de carregamento
      // return Center(
      //   child: LoadingAnimationWidget.newtonCradle(color: Colors.blue, size: 50),
      // );
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadingAnimationWidget.newtonCradle(color: Colors.blue, size: 50),
          const SizedBox(height: 20),
          const Text('Carregando tarefas...'),
        ],
      );
    }

    return Expanded(
      child: _buildTaskList(showArchived: false, showDeleted: false),
    );

    // Aqui você pode buscar as tarefas do dia selecionado
    // e exibi-las em uma lista. Por enquanto, vamos apenas exibir o dia selecionado.
  }

  Widget _buildTaskList(
      {required bool showArchived, bool showDeleted = false}) {
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
            isDeletedView: showDeleted,
            onToggleDone: () async {
              task.isDone = !task.isDone;
              setState(() {
                task.isDone = task.isDone;
              });
              if (task.id != null) {
                task.isDone
                    ? await ApiService.completeTask(task.id!, token)
                    : await ApiService.uncompleteTask(task.id!, token);
              }
            },
            onAction: (value) async {
              setState(() {
                isLoading = true; // Inicia o carregamento
              });

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

              switch (value) {
                case 'archive':
                  if (task.id != null) {
                    await ApiService.archiveTask(task.id!, token);
                  }
                  break;
                case 'unarchive':
                  if (task.id != null) {
                    await ApiService.unarchiveTask(task.id!, token);
                  }
                  break;
                case 'delete':
                  if (task.id != null) {
                    await ApiService.deleteTask(task.id!, token);
                  }
                  break;
                case 'restore':
                  if (task.id != null) {
                    await ApiService.restoreTask(task.id!, token);
                  }
                  break;
                case 'edit':
                  await Navigator.pushNamed(
                    context, 
                    '/edit-task',
                    arguments: task,
                  );

                  
                  break;
              }

              // Atualiza a lista de tarefas após a ação
              _loadTasks();
            },
          ),
        );
      },
    );
  }
}
