import 'dart:convert';

import '../models/task.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorageService {
  /// Adiciona uma nova tarefa via API
  static Future<void> addTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');
    await ApiService.addTask(task, token);
  }

  /// Carrega as tarefas do usuário via API
  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');
    return await ApiService.getTasks(token);
  }

  /// Editar uma tarefa via API
  static Future<void> editTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');
    await ApiService.editTask(task, token);
  }

  /// Obtem as tarefas deletadas do usuário via API
  static Future<List<Map<String, dynamic>>> loadDeletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');
    return await ApiService.getDeletedTasks(token);
  }

  /// Deleta uma tarefa via API
  static Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');
    await ApiService.deleteTask(taskId, token);
  }

  /// Restaura uma tarefa deletada via API
  static Future<void> restoreTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');
    await ApiService.restoreTask(taskId, token);
  }

  /// Essa função de salvar todas as tarefas localmente pode ser removida
  @deprecated
  static Future<void> saveTasks(List<Task> tasks) async {
    // Obsoleto
  }

  /// Método temporário: migra tarefas locais e depois remove
  static Future<void> migrateLocalTasksToApi(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('tasks');
    if (jsonStr == null) return;

    final List decoded = jsonDecode(jsonStr);
    final localTasks = decoded.map((e) => Task.fromJson(e)).toList();

    try {
      for (final task in localTasks) {
        await ApiService.addTask(task, token);
      }

      await prefs.remove('tasks');
      print('Tarefas locais migradas com sucesso');
    } catch (e) {
      print('Erro ao migrar tarefas locais: $e');
    }
  }
}
