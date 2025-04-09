import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  Future<void> scanBarcode(BuildContext context) async {
    String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.BARCODE);
    if (barcode != "-1") {
      final item = await ApiService.fetchItem(barcode);
      if (item != null) {
        Provider.of<Cart>(context, listen: false).addItem(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QuickPass")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => scanBarcode(context),
              child: Text("Scan Item", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
              child: Text("View Cart", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}