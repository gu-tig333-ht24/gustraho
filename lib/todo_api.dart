import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoApi {
  final String _baseUrl = 'https://todoapp-api.apps.k8s.gu.se';
  late String _apiKey;

  TodoApi(this._apiKey);

  // Hämta alla todos från API (GET)
  Future<List<Map<String, dynamic>>> fetchTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos?key=$_apiKey'));

    if (response.statusCode == 200) {
      List<dynamic> todosJson = json.decode(response.body);
      return todosJson.map((todo) => {
        'id': todo['id'],
        'task': todo['title'],
        'completed': todo['done'],
      }).toList();
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  // Lägg till en ny Todo (POST)
Future<Map<String, dynamic>> addTodoItem(String task) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/todos?key=$_apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'title': task,
      'done': false,
    }),
  );

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    if (jsonResponse is List) {
      return Map<String, dynamic>.from(jsonResponse.first); // Returnera första uppgiften
    } else if (jsonResponse is Map) {
      return Map<String, dynamic>.from(jsonResponse); // Returnera objekt om det är en map
    } else {
      throw Exception("Unexpected response format");
    }
  } else {
    throw Exception('Failed to add todo');
  }
}

  // Uppdatera en befintlig Todo (PUT)
  Future<void> updateTodoItem(String id, bool completed, String title) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/todos/$id?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'done': completed,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }

  // Ta bort en Todo (DELETE)
  Future<void> deleteTodoItem(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id?key=$_apiKey'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}
