import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo_app/services/task_storage_service.dart';

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction action) async {
  if (action.buttonKeyPressed == 'MARK_DONE') {
    final taskId = action.payload?['task_id'];
    if (taskId != null) {
      await TaskStorageService.completeTask(taskId);
      print("Tarefa $taskId marcada como feita (em segundo plano).");
    }
  }
}
