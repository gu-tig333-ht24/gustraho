import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<Map<String, dynamic>> _todoItems = [];
  String _filter = 'All'; 

  // Funktion för att hämta api nyckeln
  Future<String> getApiKey() async {
    final response = await http.get(Uri.parse('https://todoapp-api.apps.k8s.gu.se/register'));

    if (response.statusCode == 200) {
      return response.body; 
    } else {
      throw Exception('Failed to load API key');
    }
  }

  // Funktion för att hämta todos från api:et (GET)
  Future<void> fetchTodos(String apiKey) async {
    final response = await http.get(
      Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> todosJson = json.decode(response.body); 
      setState(() {
        _todoItems.clear();  
        for (var todo in todosJson) {
          _todoItems.add({
            'id': todo['id'],
            'task': todo['title'], 
            'completed': todo['done'],
          });
        }
      });
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  // Funktion för att lägga till en todo i API:et (POST)
  Future<void> addTodoItem(String task, String apiKey) async {
    final response = await http.post(
      Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': task,
        'done': false,
      }),
    );


    if (response.statusCode == 200) {
      fetchTodos(apiKey); // Uppdatera listan efter att en uppgift har lagts till
    } else {
      throw Exception('Failed to add todo');
    }
  }

  // Funktion för att uppdatera en todo i API:et (PUT)
  Future<void> updateTodoItem(int index, String apiKey) async {
    final todo = _todoItems[index];
    final response = await http.put(
      Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos/${todo['id']}?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': todo['task'],
        'done': !todo['completed'],
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _todoItems[index]['completed'] = !_todoItems[index]['completed'];
      });
    } else {
      throw Exception('Failed to update todo');
    }
  }

  // Funktion för att ta bort en todo API:et (DELETE)
  Future<void> deleteTodoItem(int index, String apiKey) async {
    final todo = _todoItems[index];
    final response = await http.delete(
      Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos/${todo['id']}?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _todoItems.removeAt(index);
      });
    } else {
      throw Exception('Failed to delete todo');
    }
  }

  @override
  void initState() {
    super.initState();
    getApiKey().then((apiKey) {
      fetchTodos(apiKey);
    }).catchError((error) {
      print("Failed to fetch API key: $error");
    });
  }

  List<Map<String, dynamic>> _filteredTodoItems() { 
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
        title: const Text('TIG333 TODO'),
        centerTitle: true,
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
                getApiKey().then((apiKey) {
                  updateTodoItem(index, apiKey);
                });
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
                getApiKey().then((apiKey) {
                  deleteTodoItem(index, apiKey);
                });
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
        getApiKey().then((apiKey) {
          addTodoItem(newTask, apiKey); 
        });
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
