import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Listas de Tareas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TaskListManager(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  
  Task(this.title, {this.isCompleted = false});
}

class TaskList {
  String name;
  List<Task> tasks;
  
  TaskList(this.name, {List<Task>? tasks}) : tasks = tasks ?? [];
}

class TaskListManager extends StatefulWidget {
  const TaskListManager({super.key});

  @override
  _TaskListManagerState createState() => _TaskListManagerState();
}

class _TaskListManagerState extends State<TaskListManager> {
  final List<TaskList> _taskLists = [];
  final TextEditingController _listController = TextEditingController();

  void _addTaskList() {
    if (_listController.text.isNotEmpty) {
      setState(() {
        _taskLists.add(TaskList(_listController.text));
        _listController.clear();
      });
    }
  }

  void _openTaskList(TaskList taskList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskListScreen(taskList: taskList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LukiTask')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _listController,
                    decoration: InputDecoration(
                      hintText: 'Nombre de la nueva lista',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTaskList,
                  child: Text('Crear Lista'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _taskLists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_taskLists[index].name),
                  onTap: () => _openTaskList(_taskLists[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final TaskList taskList;

  const TaskListScreen({super.key, required this.taskList});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        widget.taskList.tasks.add(Task(_taskController.text));
        _taskController.clear();
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      widget.taskList.tasks[index].isCompleted = !widget.taskList.tasks[index].isCompleted;
    });
  }

  void _removeTask(int index) {
    setState(() {
      widget.taskList.tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskList.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Agregar una nueva tarea',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.taskList.tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: widget.taskList.tasks[index].isCompleted,
                    onChanged: (value) => _toggleTask(index),
                  ),
                  title: Text(
                    widget.taskList.tasks[index].title,
                    style: TextStyle(
                      decoration: widget.taskList.tasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
