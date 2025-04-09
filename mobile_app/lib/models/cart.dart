import 'package:flutter/material.dart';
import 'item.dart';

class Cart with ChangeNotifier {
  List<Item> _items = [];
  int get itemCount => _items.length;

  List<Item> get items => _items;

  void addItem(Item item) {
    if (_items.length < 5) {
      _items.add(item);
      notifyListeners();
    } else {
      // Show error dialog
    }
  }

  double get total => _items.fold(0, (sum, item) => sum + item.price);
}