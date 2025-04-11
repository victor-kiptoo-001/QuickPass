import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quickpass/l10n/app_localizations.dart';

class BarcodeScanner {
  static Future<String?> scan(BuildContext context) async {
    try {
      final controller = MobileScannerController();
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _ScannerDialog(controller: controller),
      );
      controller.dispose();
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorScanning),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }
}

class _ScannerDialog extends StatefulWidget {
  final MobileScannerController controller;

  const _ScannerDialog({required this.controller});

  @override
  State<_ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<_ScannerDialog> {
  final _manualController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.scanBarcode,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: MobileScanner(
                controller: widget.controller,
                onDetect: (barcode) {
                  if (barcode.barcodes.isNotEmpty) {
                    Navigator.pop(context, barcode.barcodes.first.rawValue);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _manualController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.manualEntry,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_manualController.text.isNotEmpty) {
                        Navigator.pop(context, _manualController.text);
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.submit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }
}