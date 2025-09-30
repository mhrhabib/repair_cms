import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/screens/eleven/job_booking_file_upload_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/core/app_exports.dart';

class JobBookingAddItemsScreen extends StatefulWidget {
  const JobBookingAddItemsScreen({super.key});

  @override
  State<JobBookingAddItemsScreen> createState() => _JobBookingAddItemsScreenState();
}

class _JobBookingAddItemsScreenState extends State<JobBookingAddItemsScreen> {
  final TextEditingController _itemController = TextEditingController();
  List<ItemModel> selectedItems = [];

  final List<ItemModel> items = [
    ItemModel(name: 'Protection case', price: 29.90, quality: 'Premium'),
    ItemModel(name: 'Good case', price: 19.90, quality: 'Good'),
    ItemModel(name: 'Basic Insurance', price: 15.50, quality: 'Standard'),
    ItemModel(name: 'Premium Insurance', price: 35.00, quality: 'Premium'),
    ItemModel(name: 'Tempered Glass', price: 12.90, quality: 'Premium'),
    ItemModel(name: 'Plastic Film', price: 7.50, quality: 'Basic'),
  ];

  @override
  void initState() {
    super.initState();
    _itemController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Progress bar
            SliverToBoxAdapter(
              child: Container(
                height: 4,
                width: double.infinity,
                color: Colors.grey[300],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(height: 4, width: MediaQuery.of(context).size.width * 1.0, color: Colors.blue),
                ),
              ),
            ),

            // Header
            SliverToBoxAdapter(
              child: Padding(
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
            ),

            // Step indicator
            SliverToBoxAdapter(
              child: Center(
                child: Container(
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
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            // Title and subtitle
            SliverToBoxAdapter(
              child: const Column(
                children: [
                  Text(
                    'Add Items',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text('(Protection case, Insurance...)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 32)),

            // Item Dropdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Item',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    CustomDropdownSearch<ItemModel>(
                      controller: _itemController,
                      items: items,
                      hintText: 'Select item',
                      noItemsText: 'No items found',
                      onSuggestionSelected: (ItemModel item) {
                        setState(() {
                          if (!selectedItems.contains(item)) {
                            selectedItems.add(item);
                          }
                          _itemController.text = '';
                        });
                      },
                      itemBuilder: (BuildContext context, ItemModel item) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                                    ),
                                    Text(
                                      '${item.price.toStringAsFixed(2)} € - ${item.quality}',
                                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      suggestionsCallback: (String pattern) {
                        return items.where((item) => item.name.toLowerCase().contains(pattern.toLowerCase())).toList();
                      },
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                      maxHeight: 200.h,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Selected Items
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Items',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    if (selectedItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('No items selected yet', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedItems.map((item) => _buildSelectedItemCard(item)).toList(),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Add extra space at the bottom for the button
            SliverToBoxAdapter(child: const SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8, left: 24, right: 24),
        child: BottomButtonsGroup(
          onPressed: () {
            // Handle form submission with selected items
            Navigator.push(context, MaterialPageRoute(builder: (context) => const JobBookingFileUploadScreen()));
          },
        ),
      ),
    );
  }

  Widget _buildSelectedItemCard(ItemModel item) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} € - ${item.quality}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedItems.remove(item);
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class ItemModel {
  final String name;
  final double price;
  final String quality;

  ItemModel({required this.name, required this.price, required this.quality});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price &&
          quality == other.quality;

  @override
  int get hashCode => name.hashCode ^ price.hashCode ^ quality.hashCode;

  @override
  String toString() {
    return name;
  }
}
