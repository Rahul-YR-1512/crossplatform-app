import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Firebase is configured.
const bool firebaseConfigured = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (firebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const StockInventoryApp());
}

class StockInventoryApp extends StatelessWidget {
  const StockInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2457C5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Inventory Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFDCE2ED),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const InventoryHome(),
    );
  }
}

class StockItem {
  final String id;
  final String sku;
  final String itemName;
  final String category;
  final int quantity;
  final double unitPrice;
  final int reorderLevel;
  final DateTime? createdAt;

  const StockItem({
    required this.id,
    required this.sku,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.reorderLevel,
    this.createdAt,
  });

  bool get isLowStock => quantity <= reorderLevel;

  factory StockItem.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'];

    return StockItem(
      id: id,
      sku: data['sku'] as String? ?? '',
      itemName: data['itemName'] as String? ?? '',
      category: data['category'] as String? ?? '',
      quantity: (data['quantity'] as num? ?? 0).toInt(),
      unitPrice: (data['unitPrice'] as num? ?? 0).toDouble(),
      reorderLevel: (data['reorderLevel'] as num? ?? 0).toInt(),
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'sku': sku,
    'itemName': itemName,
    'category': category,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'reorderLevel': reorderLevel,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class InventoryHome extends StatefulWidget {
  const InventoryHome({super.key});

  @override
  State<InventoryHome> createState() => _InventoryHomeState();
}

class _InventoryHomeState extends State<InventoryHome> {
  int _tab = 0;

  final List<StockItem> _demoItems = [];
  final _formKey = GlobalKey<FormState>();

  final _sku = TextEditingController();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _reorder = TextEditingController();

  String? _category;
  bool _saving = false;

  final _search = TextEditingController();
  String _categoryFilter = 'All';
  bool _lowOnly = false;
  bool _ascending = true;
  int _sortMode = 0;

  static const categories = [
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  bool get _firebaseOn => firebaseConfigured;

  @override
  void dispose() {
    _sku.dispose();
    _name.dispose();
    _quantity.dispose();
    _price.dispose();
    _reorder.dispose();
    _search.dispose();
    super.dispose();
  }

  String? _validateSku(String? value) {
    final v = value?.trim() ?? '';

    return RegExp(r'^STK-\d{3}$').hasMatch(v)
        ? null
        : 'Enter SKU in the format STK-101.';
  }

  String? _validateName(String? value) {
    return (value?.trim().length ?? 0) >= 3
        ? null
        : 'Item name must contain at least 3 characters.';
  }

  String? _validateWholeNumber(String? value, String label) {
    final v = value?.trim() ?? '';
    final n = int.tryParse(v);

    if (v.isEmpty) return '$label is required.';
    if (n == null) return '$label must be a whole number.';
    if (n < 0) return '$label cannot be negative.';

    return null;
  }

  String? _validatePrice(String? value) {
    final v = value?.trim() ?? '';
    final n = double.tryParse(v);

    if (v.isEmpty || n == null || n <= 0) {
      return 'Enter a price greater than RM 0.00.';
    }

    return null;
  }

  Future<void> _saveItem() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final item = StockItem(
      id: '',
      sku: _sku.text.trim().toUpperCase(),
      itemName: _name.text.trim(),
      category: _category!,
      quantity: int.parse(_quantity.text.trim()),
      unitPrice: double.parse(_price.text.trim()),
      reorderLevel: int.parse(_reorder.text.trim()),
      createdAt: DateTime.now(),
    );

    try {
      if (_firebaseOn) {
        await FirebaseFirestore.instance
            .collection('stockItems')
            .add(item.toMap());
      } else {
        _demoItems.insert(
          0,
          item.copyWithId(
            DateTime.now().microsecondsSinceEpoch.toString(),
          ),
        );
      }

      if (!mounted) return;

      _sku.clear();
      _name.clear();
      _quantity.clear();
      _price.clear();
      _reorder.clear();

      setState(() {
        _category = null;
        _saving = false;
        _tab = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _firebaseOn
                ? 'Item saved to Cloud Firestore.'
                : 'Demo item saved locally. Configure Firebase for cloud storage.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save item: $e'),
        ),
      );
    }
  }

  Stream<List<StockItem>> _firestoreStream() {
    return FirebaseFirestore.instance
        .collection('stockItems')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => StockItem.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  List<StockItem> _visibleItems(List<StockItem> items) {
    final keyword = _search.text.trim().toLowerCase();

    final filtered = items.where((item) {
      final matchesKeyword = keyword.isEmpty ||
          item.itemName.toLowerCase().contains(keyword) ||
          item.sku.toLowerCase().contains(keyword);

      final matchesCategory =
          _categoryFilter == 'All' || item.category == _categoryFilter;

      final matchesLow = !_lowOnly || item.isLowStock;

      return matchesKeyword && matchesCategory && matchesLow;
    }).toList();

    if (_sortMode != 0) {
      filtered.sort(
            (a, b) => _ascending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity),
      );
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _search.clear();
      _categoryFilter = 'All';
      _lowOnly = false;
      _sortMode = 0;
      _ascending = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Inventory Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                avatar: Icon(
                  _firebaseOn
                      ? Icons.cloud_done
                      : Icons.science_outlined,
                  size: 17,
                ),
                label: Text(
                  _firebaseOn ? 'Firebase connected' : 'Demo mode',
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_firebaseOn)
              Container(
                width: double.infinity,
                color: const Color(0xFFFFF3D6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: const Text(
                  'Demo mode: data stays on this screen session. Follow README to connect your Firebase project.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF754D00),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Add Stock'),
                    icon: Icon(Icons.add_box_outlined),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Inventory'),
                    icon: Icon(Icons.inventory_2_outlined),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (value) {
                  setState(() => _tab = value.first);
                },
              ),
            ),
            Expanded(
              child: _tab == 0 ? _buildForm() : _buildInventory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add a stock item',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Enter all six required fields.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 22),
                    _field(
                      'SKU',
                      _sku,
                      hint: 'STK-101',
                      validator: _validateSku,
                      icon: Icons.qr_code,
                    ),
                    _field(
                      'Item name',
                      _name,
                      hint: 'USB C Cable',
                      validator: _validateName,
                      icon: Icons.inventory_2_outlined,
                    ),
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 7),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        hintText: 'Select category',
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
                      validator: (v) => v == null
                          ? 'Please select a category.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      'Quantity',
                      _quantity,
                      hint: '4',
                      numeric: true,
                      validator: (v) =>
                          _validateWholeNumber(v, 'Quantity'),
                      icon: Icons.numbers,
                    ),
                    _field(
                      'Unit price (RM)',
                      _price,
                      hint: '19.90',
                      numeric: true,
                      decimal: true,
                      validator: _validatePrice,
                      icon: Icons.payments_outlined,
                    ),
                    _field(
                      'Reorder level',
                      _reorder,
                      hint: '5',
                      numeric: true,
                      validator: (v) =>
                          _validateWholeNumber(v, 'Reorder level'),
                      icon: Icons.warning_amber_outlined,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveItem,
                        icon: _saving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? 'Saving...' : 'Save Item',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        required String hint,
        required String? Function(String?) validator,
        required IconData icon,
        bool numeric = false,
        bool decimal = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: numeric
                ? TextInputType.numberWithOptions(decimal: decimal)
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventory() {
    if (_firebaseOn) {
      return StreamBuilder<List<StockItem>>(
        stream: _firestoreStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _stateMessage(
              Icons.error_outline,
              'Could not load inventory.',
              '${snapshot.error}',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _inventoryContent(snapshot.data ?? []);
        },
      );
    }

    return _inventoryContent(List<StockItem>.from(_demoItems));
  }

  Widget _inventoryContent(List<StockItem> allItems) {
    final items = _visibleItems(allItems);
    final lowCount = allItems.where((e) => e.isLowStock).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search item name or SKU...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _search.clear()),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoryFilter,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: ['All', ...categories]
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(
                            () => _categoryFilter = v ?? 'All',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sortMode == 0
                          ? 'No sort'
                          : (_ascending
                          ? 'Qty: low to high'
                          : 'Qty: high to low'),
                      decoration: const InputDecoration(
                        labelText: 'Sort by',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: const [
                        'No sort',
                        'Qty: low to high',
                        'Qty: high to low',
                      ]
                          .map(
                            (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _sortMode = v == 'No sort' ? 0 : 1;
                        _ascending = v != 'Qty: high to low';
                      }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      selected: _lowOnly,
                      onSelected: (v) => setState(() => _lowOnly = v),
                      avatar: const Icon(
                        Icons.warning_amber,
                        size: 18,
                      ),
                      label: Text('Low stock only ($lowCount)'),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? _stateMessage(
            Icons.inventory_2_outlined,
            'No inventory items found.',
            allItems.isEmpty
                ? 'Add your first stock item using the Add Stock tab.'
                : 'Try changing your search or filters.',
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _itemCard(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _itemCard(StockItem item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: item.isLowStock
                        ? const Color(0xFFFFE9E6)
                        : const Color(0xFFE5F6EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isLowStock ? 'Low stock' : 'In stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.isLowStock
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${item.sku}  •  ${item.category}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
            const Divider(height: 22),
            Wrap(
              spacing: 22,
              runSpacing: 10,
              children: [
                _metric('Quantity', '${item.quantity}'),
                _metric(
                  'Unit price',
                  'RM ${item.unitPrice.toStringAsFixed(2)}',
                ),
                _metric('Reorder level', '${item.reorderLevel}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return SizedBox(
      width: 105,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _stateMessage(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

extension on StockItem {
  StockItem copyWithId(String newId) => StockItem(
    id: newId,
    sku: sku,
    itemName: itemName,
    category: category,
    quantity: quantity,
    unitPrice: unitPrice,
    reorderLevel: reorderLevel,
    createdAt: createdAt,
  );
}