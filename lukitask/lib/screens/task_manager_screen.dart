import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lukitask/widgets/custom_app_bar.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _listController = TextEditingController();
  String? uid;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  /// Obtiene el usuario actual de FirebaseAuth
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("✅ Usuario autenticado: ${user.uid}");
      
      setState(() {
        uid = user.uid;
      });

      // 🔥 Verificar si Firestore tiene listas de tareas guardadas
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('taskLists')
          .get()
          .then((snapshot) {
        print("📂 Listas de tareas en Firestore: ${snapshot.docs.length}");
        for (var doc in snapshot.docs) {
          print("📌 Lista encontrada: ${doc.id}");
        }
      }).catchError((e) {
        print("❌ Error al obtener listas de Firestore: $e");
      });

    } else {
      print("⚠️ No hay usuario autenticado, redirigiendo a login...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Redirige si no está autenticado
      );
    }
  }


  void _addTaskList() async {
    if (uid == null) return;
    if (_listController.text.isNotEmpty) {
      await _firestoreService.saveTaskList(uid!, _listController.text);
      _listController.clear();
    }
  }

  void _removeTaskList(String listName) async {
    if (uid == null) return;
    await _firestoreService.deleteTaskList(uid!, listName);
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Mostramos un loading hasta que se obtenga el usuario
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestor de Listas de Tareas'),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('taskLists')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay listas de tareas aún."));
                }

                var taskLists = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: taskLists.length,
                  itemBuilder: (context, index) {
                    String listName = taskLists[index].id;
                    return ListTile(
                      title: Text(listName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTaskList(listName),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskListScreen(taskListName: listName),
                          ),
                        );
                      },
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


/*
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
*/