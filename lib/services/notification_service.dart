
import 'dart:ffi';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  /// Inicializa o plugin e canal de notificações
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_notification',
      [
        NotificationChannel(
          channelKey: 'task_channel',
          channelName: 'Task Notifications',
          channelDescription: 'Notificações agendadas para tarefas',
          defaultColor: const Color(0xFF00A86B),
          ledColor: const Color(0xFFFFFFFF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          icon: 'resource://mipmap/ic_notification',
        )
      ],
      debug: true,
    );

    await requestPermission();
  }

  /// Verifica se tem permissão para notificação, e solicita se necessário
  static Future<void> requestPermission() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    } catch (e) {
      // Se der erro, pode ser que o usuário tenha negado a permissão
      // ou o app não tenha permissão para enviar notificações
      AlertDialog(
        title: const Text('Permissão de Notificação'),
        content: const Text(
          'Para receber lembretes, você precisa permitir notificações.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Aqui você pode abrir as configurações do app
              // para o usuário habilitar as notificações
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      );
    }
  }

  static int generateNotificationId(String uniqueId, int offset) {
    return uniqueId.hashCode + offset;
  }
  /// Agenda 3 notificações antes da data da tarefa
  static Future<void> scheduleTaskNotifications({
    required String idBase,
    required String title,
    required DateTime date,
  }) async {
    final times = [
      date.subtract(const Duration(hours: 1)),
      date.subtract(const Duration(minutes: 30)),
      date.subtract(const Duration(minutes: 10)),
    ];

    final messages = [
      'Faltam 1 hora para sua tarefa "$title"',
      'Faltam 30 minutos para sua tarefa "$title"',
      'Faltam 10 minutos para sua tarefa "$title"',
    ];

    const timeZone = 'America/Sao_Paulo'; // Ajuste conforme necessário

    for (int i = 0; i < times.length; i++) {
      if (times[i].isAfter(DateTime.now())) {
        final notificationId = generateNotificationId(idBase, i);
        print('Scheduling notification ${notificationId} for ${times[i]}');
        try {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: notificationId,
              channelKey: 'task_channel',
              title: 'Lembrete de tarefa',
              body: messages[i],
              notificationLayout: NotificationLayout.Default,
              category: NotificationCategory.Reminder,
              icon: 'resource://mipmap/ic_notification',
              payload: {
                'task_id': idBase.toString(),
                'task_title': title,
              },
            ),
            schedule: NotificationCalendar(
              year: times[i].year,
              month: times[i].month,
              day: times[i].day,
              hour: times[i].hour,
              minute: times[i].minute,
              second: 0,
              millisecond: 0,
              preciseAlarm: true,
              timeZone: timeZone,
            ),
            actionButtons: [
              NotificationActionButton(
                key: 'MARK_DONE',
                label: 'Marcar como feita',
                actionType: ActionType.SilentBackgroundAction,
              ),
            ],
          );
          print('Notificação ${notificationId} agendada para ${times[i]}');
        } catch (e) {
          print('Erro ao agendar notificação ${notificationId}: $e');
        }
      }
    }
  }

  /// Cancela todas as notificações agendadas (caso queira resetar)
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
}
