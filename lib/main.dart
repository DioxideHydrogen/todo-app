import 'package:flutter/material.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/services/task_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await NotificationService.init();
    print('Notification service initialized');
  } catch (e, stack) {
    print('Erro ao inicializar notificações: $e');
    print(stack);
  }

  final prefs = await SharedPreferences.getInstance();

 String? uuid = prefs.getString('uuid');
  if (uuid == null) {
    uuid = const Uuid().v4();
    await prefs.setString('uuid', uuid);
  }

  String? token = prefs.getString('token');
  if (token == null) {
    token = await ApiService.registerOrLogin(uuid);
    await prefs.setString('token', token);
  }
  
  await TaskStorageService.migrateLocalTasksToApi(token);

  runApp(MyApp(token: token));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.token});
  final String token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet List',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: MyHomePage(title: 'My Tasks', token: token),
    );
  }
}
