import 'package:flutter_todo_app/models/task.dart';
import 'package:flutter_todo_app/providers/database_provider.dart';
import 'package:get/get.dart';

// Abstracts away logic for the home page (basically controls the state of the home page) by managing the currently selected date and tasks
class HomeController extends GetxController {
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  DateTime get selectedDate => _selectedDate.value;

  final Rx<List<Task>> _myTasks = Rx<List<Task>>([]);

  List<Task> get myTasks => _myTasks.value;

  @override
  void onInit() {
    super.onInit();
    getTasks();
  }

  // get tasks from the db, parsing it into the proper form for the UI component (home_screen.dart) to display
  getTasks() async {
    final List<Task> tasksFromDB = [];
    List<Map<String, dynamic>> tasks = await DatabaseProvider.queryTasks();
    tasksFromDB.assignAll(
        tasks.reversed.map((data) => Task().fromJson(data)).toList());
    _myTasks.value = tasksFromDB;
  }

  // delete task by querying the db
  Future<int> deleteTask(String id) async {
    return await DatabaseProvider.deleteTask(id);
  }

  // update task by querying the db
  Future<int> upDateTask(String id) async {
    return await DatabaseProvider.updateTask(id);
  }

  // change the selected date
  updateSelectedDate(DateTime date) {
    _selectedDate.value = date;
    getTasks();
  }
}
