import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_app/models/task.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  /// Registra ou autentica um usuário com base no UUID
  static Future<String> registerOrLogin(String uuid) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uuid': uuid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Usuário autenticado com sucesso: ${data['token']}');
      print('UUID: $uuid');
      return data['token'];
    } else {
      throw Exception('Falha ao autenticar o usuário');
    }
  }

  /// Lista tarefas do usuário autenticado
  static Future<List<Map<String, dynamic>>> getTasks(String token) async {
    print('Buscando tarefas para o token: $token');
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Tarefas recebidas com sucesso');	
      final List data = jsonDecode(response.body);
      print('Total de tarefas recebidas: ${data.length}');
      print('Tarefas: $data');
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Erro ao buscar tarefas: ${response.statusCode} - ${response.body}');
      throw Exception('Erro ao buscar tarefas');
    }
  }

  /// Lista tarefas deletadas do usuário autenticado
  static Future<List<Map<String, dynamic>>> getDeletedTasks(String token) async {
    print('Buscando tarefas deletadas para o token: $token');
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks/deleted'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Tarefas deletadas recebidas com sucesso');
      final List data = jsonDecode(response.body);
      print('Total de tarefas deletadas recebidas: ${data.length}');
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Erro ao buscar tarefas deletadas: ${response.statusCode} - ${response.body}');
      throw Exception('Erro ao buscar tarefas deletadas');
    }
  }

  /// Cria uma nova tarefa
  static Future<Task> addTask(Task task, String token) async {
    print('Criando tarefa: ${task.title} - ${task.description}');
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJsonForApi()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar tarefa');
    }

    print('Tarefa criada com sucesso: ${task.title}');
    final data = jsonDecode(response.body);
    return Task.fromJsonApi(data);
  }

  /// Edita uma tarefa existente
  static Future<void> editTask(Task task, String token) async {
    print('Editando tarefa: ${task.id} - ${task.title}');
    final response = await http.patch(
      Uri.parse('$_baseUrl/tasks/${task.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJsonForApi()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao editar tarefa');
    }
  }

  /// Arquivar uma tarefa
  static Future<void> archiveTask(String taskId, String token) async {
    print('Arquivando tarefa: $taskId');
    final response = await http.patch(
      Uri.parse('$_baseUrl/tasks/$taskId/archive'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao arquivar tarefa');
    }
  }

  /// Desarquivar uma tarefa
  static Future<void> unarchiveTask(String taskId, String token) async {
    print('Desarquivando tarefa: $taskId');
    final response = await http.patch(
      Uri.parse('$_baseUrl/tasks/$taskId/unarchive'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao desarquivar tarefa');
    }
  }

  /// Completar uma tarefa
  static Future<void> completeTask(String taskId, String token) async {
    print('Completando tarefa: $taskId');
    final response = await http.patch(
      Uri.parse('$_baseUrl/tasks/$taskId/complete'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao completar tarefa');
    }
  }

  /// Desmarcar uma tarefa como completa
  static Future<void> uncompleteTask(String taskId, String token) async {
    print('Desmarcando tarefa: $taskId');
    final response = await http.patch(
      Uri.parse('$_baseUrl/tasks/$taskId/uncomplete'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao desmarcar tarefa');
    }
  }

  /// Soft delete de uma tarefa
  static Future<void> deleteTask(String taskId, String token) async {
    print('Excluindo tarefa: $taskId');
    final response = await http.delete(
      Uri.parse('$_baseUrl/tasks/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao excluir tarefa');
    }
  }

  /// Deleta uma tarefa permanentemente
  static Future<void> deleteTaskPermanently(String taskId, String token) async {
    print('Deletando permanentemente tarefa: $taskId');
    final response = await http.delete(
      Uri.parse('$_baseUrl/tasks/$taskId/permanently'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao deletar tarefa permanentemente');
    }
  }

  /// Restaura uma tarefa deletada
  static Future<void> restoreTask(String taskId, String token) async {
    print('Restaurando tarefa: $taskId');
    final response = await http.patch(
      Uri.parse('$_baseUrl/tasks/$taskId/restore'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao restaurar tarefa');
    }
  }
}
