// ignore_for_file: avoid_print

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:todo_app/models/tag.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/add_tag_page.dart';
import 'package:todo_app/pages/add_task_page.dart';
import 'package:todo_app/pages/calendar_page.dart';
import 'package:todo_app/pages/edit_tag_page.dart';
import 'package:todo_app/pages/edit_task_page.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/pages/settings_page.dart';
import 'package:todo_app/pages/tags_page.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/services/task_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_app/controllers/notification_controller.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  print('Token: $token');
  print('Setting up Awesome Notifications Listeners');
  await AwesomeNotifications()
      .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  print('Awesome Notifications Listeners set up successfully');

  await initializeDateFormatting();

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/calendar':
            return MaterialPageRoute(builder: (_) => const CalendarPage());

          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsPage());

          case '/edit-task':
            final task = settings.arguments as Task;
            return MaterialPageRoute(
              builder: (_) => EditTaskPage(task: task),
            );
          case '/tags':
            return MaterialPageRoute(
              builder: (_) => const TagsPage(),
            );
          case '/add-tag':
            return MaterialPageRoute(
              builder: (_) => const AddTagPage(),
            );
          case '/edit-tag':
            final tag = settings.arguments as Tag;
            return MaterialPageRoute(
              builder: (_) => EditTagPage(tag: tag),
            );
          default:
            return MaterialPageRoute(builder: (_) => const CalendarPage());
        }
      },
      home: MyHomePage(title: 'My Tasks', token: token),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Portuguese (Brazil)
        Locale('en', 'US'), // English (United States)
      ],
    );
  }
}
