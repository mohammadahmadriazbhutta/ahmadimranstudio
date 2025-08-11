import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class EditCustomerSizesPage extends StatefulWidget {
  final String customerId;
  final String customerName;

  const EditCustomerSizesPage({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<EditCustomerSizesPage> createState() => _EditCustomerSizesPageState();
}

class _EditCustomerSizesPageState extends State<EditCustomerSizesPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController notesController = TextEditingController();

  final Map<String, List<String>> sizeCategories = {
    "Shalwar Kameez": [
      "Kameez Length",
      "Shoulder",
      "Neck",
      "Sleeves",
      "Chest",
      "Waist",
      "Hip",
      "Width",
      "Tummy",
      "Cuff",
      "Armhole",
      "Bicep",
      "Side Pocket",
      "Front Pocket",
      "Shalwar Length",
      "Shalwar Width",
      "Crotch",
      "Shalwar Pocket",
    ],
    "Coat": [
      "Coat Length",
      "Shoulder",
      "Sleeves",
      "Chest",
      "Waist",
      "Tummy",
      "Hip",
      "Cross",
      "Pant Length",
      "Thigh",
      "Bottom",
    ],
    "Waist Coat": ["Waist Coat Length", "Chest", "Neck"],
  };

  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final doc = await _db
          .collection('customers')
          .doc(widget.customerId)
          .get();
      final data = doc.data();

      // Default to Shalwar Kameez on load
      selectedCategory = sizeCategories.keys.first;

      for (var category in sizeCategories.keys) {
        for (var field in sizeCategories[category]!) {
          _controllers[field] = TextEditingController(
            text: data != null && data['sizes'] != null
                ? (data['sizes'][field]?.toString() ?? '')
                : '',
          );
        }
      }

      // Load existing special notes if any
      if (data != null && data['specialNotes'] != null) {
        notesController.text = data['specialNotes'];
      }

      setState(() {});
    } catch (e) {
      debugPrint("Error loading sizes: $e");
    }
  }

  Future<void> _saveSizes() async {
    try {
      final doc = await _db
          .collection('customers')
          .doc(widget.customerId)
          .get();
      final data = doc.data();

      // Get existing sizes or empty map
      Map<String, dynamic> allSizes = data != null && data['sizes'] != null
          ? Map.from(data['sizes'])
          : {};

      // Update only selected category fields
      for (var field in sizeCategories[selectedCategory!]!) {
        allSizes[field] = _controllers[field]?.text.trim() ?? '';
      }

      await _db.collection('customers').doc(widget.customerId).update({
        'sizes': allSizes,
        'specialNotes': notesController.text.trim(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sizes saved successfully')));

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error saving sizes: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error saving sizes')));
    }
  }

  Future<void> _printSizes() async {
    final pdf = pw.Document();
    final selectedFields = sizeCategories[selectedCategory!]!;

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${widget.customerName} - $selectedCategory Sizes',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              ...selectedFields.map((field) {
                final value = _controllers[field]?.text ?? '';
                return pw.Text(
                  '$field: $value',
                  style: const pw.TextStyle(fontSize: 14),
                );
              }),
              pw.SizedBox(height: 24),
              pw.Text(
                'Special Notes:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                notesController.text,
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    if (_controllers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final fieldsToShow = selectedCategory != null
        ? sizeCategories[selectedCategory!]!
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customerName} - Sizes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printSizes,
            tooltip: 'Print',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Select Outfit',
                border: OutlineInputBorder(),
              ),
              items: sizeCategories.keys
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fieldsToShow.map((field) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 3,
                  child: TextField(
                    controller: _controllers[field],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: field,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Special Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSizes,
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
