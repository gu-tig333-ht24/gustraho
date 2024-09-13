import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoListPage(), // Första sidan
    );
  }
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> todoItems = [
      'Power nap',
      'Homework'
      'House chores'
    ];

    return Scaffold(
      backgroundColor: Color(0xFFd3eac8),
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Color(0xFFafd89d),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})
        ],
      ),
      body: ListView.builder(
        itemCount: todoItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Checkbox(value: false, onChanged: null), 
            title: Text(todoItems[index]),
            trailing: const Icon(Icons.close), 
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigera till den andra sidan
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTodoPage()),  // Andra sidan
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Gå tillbaka till första sidan
          },
        ),
        title: const Text('Add task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'What are you going to do?',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('+ ADD'),
            ),
          ],
        ),
      ),
    );
  }
}
