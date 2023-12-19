import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryitems = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'flutter-prep-afb82-default-rtdb.firebaseio.com', 'shoping-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final items in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == items.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: items.key,
          name: items.value['name'],
          quantity: items.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryitems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryitems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryitems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Items added yet.'));

    if (_isLoading = true) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryitems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryitems[index]);
          },
          key: ValueKey(_groceryitems[index].id),
          child: ListTile(
            title: Text(_groceryitems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryitems[index].category.color,
            ),
            trailing: Text(
              _groceryitems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
