import 'package:flutter/material.dart';
import 'task_list_screen.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final List<String> _taskLists = [];
  final TextEditingController _listController = TextEditingController();

  void _addTaskList() {
    if (_listController.text.isNotEmpty) {
      setState(() {
        _taskLists.add(_listController.text);
        _listController.clear();
      });
    }
  }

  void _removeTaskList(int index) {
    setState(() {
      _taskLists.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de Listas de Tareas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _listController,
                    decoration: const InputDecoration(
                      hintText: 'Nueva lista de tareas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTaskList,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _taskLists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_taskLists[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTaskList(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskListScreen(taskListName: _taskLists[index]),
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
