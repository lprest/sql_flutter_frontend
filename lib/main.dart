import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

const String apiUrl = 'https://localhost:7171/Grocery';

void main() {
  runApp(const MyApp());
}

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
    fetchGroceryItems();
  }

  Future<void> fetchGroceryItems() async {
    try {
      print('🔄 Fetching from: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));
      print('📥 Status code: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _items = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
    );
  }
}
