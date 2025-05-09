import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/views/home/model/TodoItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TodoItem> _todoItems = [];
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  // Load tasks from storage (without JSON)
  Future<void> _loadTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedItems = prefs.getStringList('todo_items');

    if (savedItems != null) {
      setState(() {
        _todoItems.addAll(
            savedItems.map((item) {
              final parts = item.split('|'); // Split by delimiter
              return TodoItem(
                title: parts[0],
                isCompleted: parts[1] == 'true',
              );
            }).toList()
        );
      });
    }
  }

  // Save tasks (without JSON)
  Future<void> _saveTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> itemsToSave = _todoItems.map((item) =>
    '${item.title}|${item.isCompleted}' // Combine with delimiter
    ).toList();
    await prefs.setStringList('todo_items', itemsToSave);
  }

  // Add new task
  void _addTodoItem(String task) {
    if (task.trim().isEmpty) return;

    setState(() {
      _todoItems.add(TodoItem(
        title: task,
        isCompleted: false,
      ));
      _saveTodoItems();
    });
    _textFieldController.clear();
  }

  // Toggle completion status
  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
      _saveTodoItems();
    });
  }

  // Delete task
  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  // Add task dialog
  Future<void> _displayDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new task'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter task here'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
                _textFieldController.clear();
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: _todoItems.isEmpty
          ? const Center(child: Text('No tasks add yet.. '))
          : ListView.builder(
        itemCount: _todoItems.length,
        itemBuilder: (context, index) {
          final item = _todoItems[index];
          return ListTile(
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (bool? value) => _toggleTodoItem(index),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.isCompleted ? Colors.grey : Colors.black,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTodoItem(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

