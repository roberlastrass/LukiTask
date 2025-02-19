import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// Importaciones Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: TaskManagerScreen(),
    );
  }
}

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
                      hintText: 'Nueva lista de tareas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTaskList,
                  child: Text('Agregar'),
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
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTaskList(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskListScreen(taskListName: _taskLists[index]),
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

class TaskListScreen extends StatefulWidget {
  final String taskListName;
  const TaskListScreen({super.key, required this.taskListName});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final Map<DateTime, List<Map<String, dynamic>>> _tasks = {};
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDay = DateTime.now();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks[_selectedDay] = (_tasks[_selectedDay] ?? [])
          ..add({"title": _controller.text, "isCompleted": false});
        _controller.clear();
      });
    }
  }

  void _toggleTask(DateTime date, int index) {
    setState(() {
      _tasks[date]![index]["isCompleted"] = !_tasks[date]![index]["isCompleted"];
    });
  }

  void _removeTask(DateTime date, int index) {
    setState(() {
      _tasks[date]?.removeAt(index);
      if (_tasks[date]?.isEmpty ?? false) {
        _tasks.remove(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskListName)),
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
                      hintText: 'Agregar tarea para ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
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
              itemCount: _tasks[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: _tasks[_selectedDay]![index]["isCompleted"],
                    onChanged: (value) => _toggleTask(_selectedDay, index),
                  ),
                  title: Text(
                    _tasks[_selectedDay]![index]["title"],
                    style: TextStyle(
                      decoration: _tasks[_selectedDay]![index]["isCompleted"]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTask(_selectedDay, index),
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