import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* GESTIÓN DE USUARIOS */

  /// Guarda un nuevo usuario en Firestore
  Future<void> createUser(String uid, String username, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al guardar usuario en Firestore: $e');
      rethrow;
    }
  }

  /// Obtiene la información de un usuario por su UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  /// Obtiene el UID de un usuario a partir del nombre de usuario
  Future<String?> getUidByUsername(String username) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error al obtener UID por username: $e');
      return null;
    }
  }


  /* LISTAS DE TAREAS */

  /// Guarda una lista de tareas en Firestore
  Future<void> saveTaskList(String uid, String listName) async {
    try {
      await _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al guardar la lista de tareas: $e');
    }
  }

  /// Obtiene las listas de tareas de un usuario
  Future<List<String>> getTaskLists(String uid) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').doc(uid).collection('taskLists').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error al obtener las listas de tareas: $e');
      return [];
    }
  }

  /// Elimina una lista de tareas de Firestore
  Future<void> deleteTaskList(String uid, String listName) async {
    try {
      final tasksCollection = _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).collection('tasks');
      final tasksSnapshot = await tasksCollection.get();
      for (var doc in tasksSnapshot.docs) {
        await doc.reference.delete();
      }
      await _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).delete();
    } catch (e) {
      print('Error al eliminar la lista de tareas: $e');
    }
  }

  /// Guarda una tarea en Firestore
  Future<void> saveTask(String uid, String listName, String taskTitle, DateTime date, bool isCompleted) async {
    try {
      await _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).collection('tasks').add({
        'title': taskTitle,
        'date': Timestamp.fromDate(date),
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print('Error al guardar la tarea: $e');
    }
  }

  /// Obtiene las tareas de una lista específica
  Stream<QuerySnapshot> getTasks(String uid, String listName) {
    return _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).collection('tasks').snapshots();
  }

  /// Marca una tarea como completada o no
  Future<void> updateTaskCompletion(String uid, String listName, String taskId, bool isCompleted) async {
    try {
      await _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print('Error al actualizar la tarea: $e');
    }
  }

  /// Elimina una tarea de Firestore
  Future<void> deleteTask(String uid, String listName, String taskId) async {
    try {
      await _firestore.collection('users').doc(uid).collection('taskLists').doc(listName).collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error al eliminar la tarea: $e');
    }
  }

}

