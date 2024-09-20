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

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  final List<Map<String, dynamic>> _todoItems = [
    {'task': 'Power nap', 'completed': false},
    {'task': 'Homework', 'completed': false},
    {'task': 'House chores', 'completed': false},
  ];

  String _filter = 'All'; // Håller reda på vilket filter som är valt

  //  lägga till en ny uppgift
    void _addTask(String task) {
    setState(() {
      _todoItems.add({'task': task, 'completed': false});
    });
  }

  // Växlar mellan klar och ej klar för en uppgift
    void _toggleTaskCompletion(int index) {
    setState(() {
      _todoItems[index]['completed'] = !_todoItems[index]['completed'];
    });
  }
  // Ta bort en uppgift
    void _removeTask(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

    // Filtrera uppgifter baserat på "All", "Done", eller "Undone"
  List<Map<String, dynamic>> _filteredTodoItems() { // NY funktion
    if (_filter == 'All') {
      return _todoItems; // Visa alla uppgifter
    } else if (_filter == 'Done') {
      return _todoItems.where((item) => item['completed'] == true).toList(); // Visa slutförda uppgifter
    } else {
      return _todoItems.where((item) => item['completed'] == false).toList(); // Visa ej slutförda uppgifter
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd3eac8),
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: const Color(0xFFafd89d),
        actions: [
          PopupMenuButton<String>(  // Popup menyn 
            onSelected: (String result) {
              setState(() {
                _filter = result;
              });
            },
            icon: const Icon(Icons.more_vert), 
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All'), 
              ),
              const PopupMenuItem<String>(
                value: 'Done',
                child: Text('Done'), 
              ),
              const PopupMenuItem<String>(
                value: 'Undone',
                child: Text('Undone'), 
              ),
            ],
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: _filteredTodoItems().length,
        itemBuilder: (context, index) {
          final todoItem = _filteredTodoItems()[index];
          return ListTile(
            leading: Checkbox(
              value: todoItem['completed'], 
              onChanged: (bool? value) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              todoItem['task'],
              style: TextStyle(
                decoration: todoItem['completed']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _removeTask(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (newTask != null && newTask.isNotEmpty) {
            _addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoPage extends StatefulWidget  {
  const AddTodoPage({super.key});

  @override
  AddTodoPageState createState() => AddTodoPageState();
}

class AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _textController = TextEditingController();

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
           TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'What are you going to do?',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final task = _textController.text;
                if (task.isNotEmpty) {
                  Navigator.pop(context, task); // Skicka tillbaka den nya uppgiften
              }
              },          
              child: const Text('+ ADD'),
            ),
          ],
        ),
      ),
    );
  }
}
