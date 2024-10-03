import 'package:flutter/material.dart';
import 'package:template/todo_api.dart'; 

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
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> _todoItems = []; // Lista för att lagra Todo-uppgifter
  String _filter = 'All'; // Filter för att visa uppgifter baserat på slutförande status
  late TodoApi todoApi; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    todoApi = TodoApi('f9c4444b-c0ef-46f3-839c-f3bd57a852c8'); // Initiera API med nyckel
    _fetchTodos(); // Hämta alla Todos vid appstart
  }

  // Hämta alla Todo-uppgifter från API och uppdatera UI
  Future<void> _fetchTodos() async {
    setState(() {
      _isLoading = true; // Visar laddningsindikator medan data hämtas
    });

    try {
      List<Map<String, dynamic>> todos = await todoApi.fetchTodos();
      setState(() {
        _todoItems = todos; // Uppdatera Todo-listan
        _isLoading = false; // Ta bort laddningsindikatorn
      });
    } catch (error) {
      print("Failed to fetch todos: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Lägg till en ny Todo-uppgift och hämta uppdaterad lista
  Future<void> _addTodoItem(String task) async {
    try {
      await todoApi.addTodoItem(task);
      _fetchTodos(); 
    } catch (error) {
      print("Failed to add todo: $error");
    }
  }

  // Uppdatera status på en Todo-uppgift 
  Future<void> _updateTodoItem(String id, bool completed, String task) async {
    try {
      await todoApi.updateTodoItem(id, completed, task);
      _fetchTodos(); 
    } catch (error) {
      print("Failed to update todo: $error");
    }
  }

  // Ta bort en Todo-uppgift och uppdatera listan
  Future<void> _deleteTodoItem(String id, int index) async {
    try {
      await todoApi.deleteTodoItem(id);
      _fetchTodos(); 
    } catch (error) {
      print("Failed to delete todo: $error");
    }
  }

  // Filtrera Todo-listan baserat på status 
  List<Map<String, dynamic>> _filteredTodoItems() {
    if (_filter == 'All') {
      return _todoItems;
    } else if (_filter == 'Done') {
      return _todoItems.where((item) => item['completed'] == true).toList();
    } else {
      return _todoItems.where((item) => item['completed'] == false).toList();
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
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _filter = result; // Uppdatera filterstatus
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Visar laddningsindikator
          : ListView.builder(
              itemCount: _filteredTodoItems().length,
              itemBuilder: (context, index) {
                final todoItem = _filteredTodoItems()[index];
                return ListTile(
                  leading: Checkbox(
                    value: todoItem['completed'],
                    onChanged: (bool? value) {
                      _updateTodoItem(todoItem['id'], value!, todoItem['task']); // Uppdatera status
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
                      _deleteTodoItem(todoItem['id'], index); // Ta bort uppgift
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTodoPage()), // Gå till sidan för att lägga till
          );
          if (newTask != null && newTask.isNotEmpty) {
            _addTodoItem(newTask); // Lägg till uppgift om något är angivet
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoPage extends StatefulWidget {
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
            Navigator.pop(context); // Gå tillbaka till listan
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
                labelText: 'What are you going to do?', // Textfält för ny uppgift
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final task = _textController.text;
                if (task.isNotEmpty) {
                  Navigator.pop(context, task); // Skicka tillbaka uppgiften
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
