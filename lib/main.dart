import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PANTRY INVENTORY'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, int>> items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemsJson = prefs.getStringList('items');
    
    if (itemsJson != null) {
      setState(() {
        items = itemsJson.map((item) => Map<String, int>.from(jsonDecode(item))).toList();
      });
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> itemsJson = items.map((item) => jsonEncode(item)).toList();
    prefs.setStringList('items', itemsJson);
  }

  void _addToList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController productController = TextEditingController();
        TextEditingController quantityController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            children: [
              TextField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Product'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String product = productController.text;
                int quantity = int.tryParse(quantityController.text) ?? 0;

                if (product.isNotEmpty && quantity > 0) {
                  setState(() {
                    items.add({product: quantity});
                  });
                  _saveData(); // Save data when adding an item
                }

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      _saveData(); // Save data when removing an item
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final MapEntry<String, int> entry = items[index].entries.first;
          final String product = entry.key;
          final int quantity = entry.value;

          return SizedBox(
            width: MediaQuery.of(context).size.width * 1.8,
            child: Card(
              child: Container(
                height: 40,
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Quantity: $quantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeItem(index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addToList,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
