import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'https://localhost:7171/Grocery';

void main() {
  runApp(const MyApp());
}

// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Grocery App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Grocery Items'),
    );
  }
}

// Home Page with Stateful Widget
class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchGroceryItems();
  }

  Future<void> _fetchGroceryItems() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _items = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _addGroceryItem(String name) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'isBought': false}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _fetchGroceryItems();
      } else {
        throw Exception('Failed to add item');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showAddItemDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grocery Item'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter item name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _controller.text.trim();
              if (name.isNotEmpty) {
                _addGroceryItem(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item['name']),
            trailing: Icon(
              item['isBought']
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}