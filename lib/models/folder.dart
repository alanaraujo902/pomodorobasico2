import 'task.dart';

class Folder {
  final String id;
  String name;
  List<Task> tasks;

  Folder({
    required this.id,
    required this.name,
    this.tasks = const [],
  });
}
