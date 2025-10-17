import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/jobItem/job_item_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/job_item_model.dart';
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
  final FocusNode _itemFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _itemController.text = '';
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      // Get userId from JobBookingCubit or your authentication system
      final userId = storage.read('userId');
      if (userId != null) {
        context.read<JobItemCubit>().searchItems(userId: userId, keyword: query);
      }
    } else {
      context.read<JobItemCubit>().clearSearch();
    }
  }

  void _addItem(Item item) {
    final cubit = context.read<JobBookingCubit>();

    // Check if item is already assigned
    if (!cubit.isItemAssigned(item.sId!)) {
      cubit.addItem(item.sId!);
    }

    // Clear search and hide keyboard
    _itemController.clear();
    _itemFocusNode.unfocus();
    context.read<JobItemCubit>().clearSearch();
  }

  void _removeItem(String itemId) {
    context.read<JobBookingCubit>().removeItem(itemId);
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: TextStyle(fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w500),
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: TextStyle(fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            backgroundColor: Colors.yellow,
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(fontSize: 16.sp, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobItemCubit, JobItemState>(
      listener: (context, state) {
        // TODO: implement listener
      },

      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Progress bar
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071 * 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                    ),
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

              // Item Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Items',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16.w),
                            Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: _itemController,
                                focusNode: _itemFocusNode,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search items by name...',
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_itemController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _itemController.clear();
                                  context.read<JobItemCubit>().clearSearch();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16.w),
                                  child: Icon(Icons.close, color: Colors.grey.shade400, size: 20.sp),
                                ),
                              )
                            else
                              SizedBox(width: 16.w),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Search Results from API
              BlocBuilder<JobItemCubit, JobItemState>(
                builder: (context, state) {
                  if (state is JobItemLoading) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (state is JobItemLoaded) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = state.itemsResponse.items![index];

                        return BlocBuilder<JobBookingCubit, JobBookingState>(
                          builder: (context, bookingState) {
                            final isAlreadySelected = bookingState is JobBookingData
                                ? bookingState.job.assignedItemsIds.contains(item.sId)
                                : false;

                            return GestureDetector(
                              onTap: () => _addItem(item),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(Icons.inventory_2_outlined, color: Colors.blue, size: 20.sp),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildHighlightedText(
                                              item.productName ?? 'Unnamed Item',
                                              state.searchQuery,
                                            ),
                                            SizedBox(height: 4.h),
                                            if (item.itemNumber != null) ...[
                                              Text(
                                                'Item #: ${item.itemNumber}',
                                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                              ),
                                              SizedBox(height: 2.h),
                                            ],
                                            if (item.manufacturer != null) ...[
                                              Text(
                                                'Manufacturer: ${item.manufacturer}',
                                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                              ),
                                              SizedBox(height: 2.h),
                                            ],
                                            if (item.stockValue != null) ...[
                                              Text(
                                                'Stock: ${item.stockValue} ${item.stockUnit ?? 'units'}',
                                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${item.salePriceIncVat?.toStringAsFixed(2) ?? '0.00'} €',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'excl. VAT',
                                            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                      if (isAlreadySelected) ...[
                                        SizedBox(width: 8.w),
                                        Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }, childCount: state.itemsResponse.items!.length),
                    );
                  }

                  if (state is JobItemNoResults) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'No items found for "${state.searchQuery}"',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is JobItemError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Error: ${state.message}',
                                style: TextStyle(fontSize: 14.sp, color: Colors.red),
                              ),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () {
                                  final userId = storage.read('userId');
                                  if (userId != null) {
                                    context.read<JobItemCubit>().refreshSearch(userId: userId);
                                  }
                                },
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Selected Items from JobBookingCubit
              BlocBuilder<JobBookingCubit, JobBookingState>(
                builder: (context, state) {
                  if (state is JobBookingData &&
                      state.job.assignedItemsIds.isNotEmpty &&
                      _itemController.text.isEmpty) {
                    return SliverToBoxAdapter(
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
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.job.assignedItemsIds
                                  .map((itemId) => _buildSelectedItemCard(itemId))
                                  .toList(),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Add extra space at the bottom for the button
              SliverToBoxAdapter(child: const SizedBox(height: 100)),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
          builder: (context, state) {
            final hasItems = state is JobBookingData && state.job.assignedItemsIds.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8, left: 24, right: 24),
              child: BottomButtonsGroup(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const JobBookingFileUploadScreen()));
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedItemCard(String itemId) {
    // In a real app, you'd want to fetch item details for display
    // For now, we'll just show the item ID
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
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
                    'Item ID: $itemId',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text('Tap to see details', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => _removeItem(itemId),
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

  @override
  void dispose() {
    _itemController.dispose();
    _itemFocusNode.dispose();
    context.read<JobItemCubit>().close();
    super.dispose();
  }
}
