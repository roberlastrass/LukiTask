import 'package:flutter/material.dart';
import 'package:lukitask/widgets/custom_app_bar.dart';
import 'task_manager_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Menú Principal'),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskManagerScreen()),
            );
          },
          child: const Text('Ir a gestor de listas'),
        ),
      ),
    );
  }
}
