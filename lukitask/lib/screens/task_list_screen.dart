import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lukitask/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class TaskListScreen extends StatefulWidget {
  final String taskListName;
  const TaskListScreen({super.key, required this.taskListName});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addTask() async {
    if (_controller.text.isEmpty) {
      _showMessage("No puedes agregar una tarea vacía");
      return;
    }

    try {
      await _firestoreService.saveTask(
        uid,
        widget.taskListName,
        _controller.text,
        _selectedDay,
        false,
      );
      _controller.clear();
      _showMessage("Tarea agregada correctamente");
    } catch (e) {
      _showMessage("Error al agregar la tarea");
    }
  }

  void _toggleTask(String taskId, bool isCompleted) async {
    try {
      await _firestoreService.updateTaskCompletion(uid, widget.taskListName, taskId, !isCompleted);
      _showMessage(isCompleted ? "Tarea marcada como pendiente" : "Tarea completada");
    } catch (e) {
      _showMessage("Error al actualizar la tarea");
    }
  }

  void _removeTask(String taskId) async {
    try {
      await _firestoreService.deleteTask(uid, widget.taskListName, taskId);
      _showMessage("Tarea eliminada correctamente");
    } catch (e) {
      _showMessage("Error al eliminar la tarea");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.taskListName),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tarea para ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getTasks(uid, widget.taskListName),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var tasks = snapshot.data!.docs.where((doc) {
                  DateTime taskDate = (doc['date'] as Timestamp).toDate();
                  return isSameDay(taskDate, _selectedDay);
                }).toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: task['isCompleted'],
                        onChanged: (value) => _toggleTask(task.id, task['isCompleted']),
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          decoration: task['isCompleted'] ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTask(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
