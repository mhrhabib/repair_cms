import 'package:flutter/material.dart';

class JobBookingAddItemsScreen extends StatefulWidget {
  const JobBookingAddItemsScreen({super.key});

  @override
  State<JobBookingAddItemsScreen> createState() => _JobBookingAddItemsScreenState();
}

class _JobBookingAddItemsScreenState extends State<JobBookingAddItemsScreen> {
  String selectedCategory = 'Protection case';
  List<String> selectedItems = [];

  final Map<String, List<ItemModel>> itemCategories = {
    'Protection case': [
      ItemModel(name: 'Protection case', price: 29.90, quality: 'Premium'),
      ItemModel(name: 'Good case', price: 19.90, quality: 'Good'),
    ],
    'Insurance': [
      ItemModel(name: 'Basic Insurance', price: 15.50, quality: 'Standard'),
      ItemModel(name: 'Premium Insurance', price: 35.00, quality: 'Premium'),
    ],
    'Screen Protector': [
      ItemModel(name: 'Tempered Glass', price: 12.90, quality: 'Premium'),
      ItemModel(name: 'Plastic Film', price: 7.50, quality: 'Basic'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              height: 4,
              width: double.infinity,
              color: Colors.grey[300],
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(height: 4, width: MediaQuery.of(context).size.width * 1.0, color: Colors.blue),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Step indicator
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Center(
                child: Text(
                  '10',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title and subtitle
            const Text(
              'Add Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),

            const SizedBox(height: 8),

            Text('(Protection case, Insurance...)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),

            const SizedBox(height: 32),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[300]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Center(child: Icon(Icons.shield_outlined, color: Colors.white, size: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black54),
                                isExpanded: true,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: itemCategories.keys.map((String category) {
                                  return DropdownMenuItem<String>(value: category, child: Text(category));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Items List
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          children: itemCategories[selectedCategory]!.map((item) => _buildItemCard(item)).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Navigation buttons
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.chevron_left, color: Colors.grey, size: 24),
                          ),
                        ),

                        const Spacer(),

                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle form submission with selected items
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    final isSelected = selectedItems.contains(item.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedItems.remove(item.name);
            } else {
              selectedItems.add(item.name);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.blue : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.quality == 'Good' ? Colors.orange : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.quality,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.price.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  Text('Incl. 20% VAT', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemModel {
  final String name;
  final double price;
  final String quality;

  ItemModel({required this.name, required this.price, required this.quality});
}
