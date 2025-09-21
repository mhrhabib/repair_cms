import 'package:repair_cms/core/app_exports.dart';
import 'one/job_booking_start_booking_job_screen.dart';

class JobBookingFirstScreen extends StatefulWidget {
  const JobBookingFirstScreen({super.key});

  @override
  State<JobBookingFirstScreen> createState() => _JobBookingFirstScreenState();
}

class _JobBookingFirstScreenState extends State<JobBookingFirstScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _hasSearchResults = false;
  List<ServiceItem> _selectedServices = [];

  final List<ServiceItem> _allServices = [
    ServiceItem(
      id: '1',
      name: 'Apple iPhone 16 LCD repair',
      category: 'iPhone 16 | Screen Replacement',
      price: 179.00,
      duration: '30-45 mins',
      description: 'Complete LCD screen replacement service',
    ),
    ServiceItem(
      id: '2',
      name: 'Apple iPhone 16 Battery replacement',
      category: 'iPhone 16 | Battery Service',
      price: 99.00,
      duration: '20-30 mins',
      description: 'Battery replacement service',
    ),
    ServiceItem(
      id: '3',
      name: 'Apple iPhone 16 Camera repair',
      category: 'iPhone 16 | Camera Replacement',
      price: 149.00,
      duration: '40-50 mins',
      description: 'Camera replacement service',
    ),
    ServiceItem(
      id: '4',
      name: 'Samsung Galaxy S24 Screen repair',
      category: 'Galaxy S24 | Screen Replacement',
      price: 199.00,
      duration: '35-45 mins',
      description: 'Complete screen replacement service',
    ),
  ];

  List<ServiceItem> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = [];
  }

  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredServices = [];
        _hasSearchResults = false;
      } else {
        _filteredServices = _allServices.where((service) {
          return service.name.toLowerCase().contains(query.toLowerCase()) ||
              service.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
        _hasSearchResults = _filteredServices.isNotEmpty;
      }
    });
  }

  void _addService(ServiceItem service) {
    setState(() {
      // Check if service is already selected to prevent duplicates
      if (!_selectedServices.any((item) => item.id == service.id)) {
        _selectedServices.add(service);
      }
    });

    // Clear search and hide keyboard
    _searchController.clear();
    _searchFocusNode.unfocus();
    _filterServices('');
  }

  void _removeService(ServiceItem service) {
    setState(() {
      _selectedServices.removeWhere((item) => item.id == service.id);
    });
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: AppTypography.fontSize16Bold.copyWith(color: Colors.black));
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: AppTypography.fontSize16Bold.copyWith(color: Colors.black, backgroundColor: Colors.yellow),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildHighlightedCategory(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: AppTypography.fontSize12.copyWith(color: Colors.blue));
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: AppTypography.fontSize12.copyWith(color: Colors.blue),
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: AppTypography.fontSize12.copyWith(color: Colors.blue, backgroundColor: Colors.yellow),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: AppTypography.fontSize12.copyWith(color: Colors.blue),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top colored bar
                  Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Close button
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(color: Color(0xFF71788F), borderRadius: BorderRadius.circular(8.r)),
                        child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Express Job badge
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12.r)),
                      child: Text(
                        'Express Job',
                        style: AppTypography.fontSize12.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Header Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Service Pricing',
                              style: AppTypography.fontSize38.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                showDialog(context: context, builder: (context) => _buildInfoDialog());
                              },
                              child: Icon(Icons.help_outline, color: Colors.grey.shade500, size: 20.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'List your service & book a job',
                          style: AppTypography.fontSize14.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w),
                          Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _filterServices,
                              decoration: InputDecoration(
                                hintText: _selectedServices.isEmpty ? 'Search services...' : 'iPhone 16 lcd repair...',
                                hintStyle: AppTypography.fontSize14.copyWith(color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _filterServices('');
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
                  ),

                  // Search Results
                  if (_searchController.text.isNotEmpty && _hasSearchResults) ...[
                    SizedBox(height: 8.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredServices.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          final isAlreadySelected = _selectedServices.any((item) => item.id == service.id);

                          return GestureDetector(
                            onTap: () => _addService(service),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildHighlightedText(service.name, _searchController.text),
                                        SizedBox(height: 4.h),
                                        _buildHighlightedCategory(service.category, _searchController.text),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${service.price.toStringAsFixed(2)} €',
                                        style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'incl. 20% VAT',
                                        style: AppTypography.fontSize10.copyWith(color: Colors.grey.shade500),
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
                          );
                        },
                      ),
                    ),
                  ],

                  // No results message
                  if (_searchController.text.isNotEmpty && !_hasSearchResults) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'no service found',
                          style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],

                  // Selected Services
                  if (_selectedServices.isNotEmpty && _searchController.text.isEmpty) ...[
                    SizedBox(height: 20.h),
                    ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _selectedServices.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final service = _selectedServices[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      service.category,
                                      style: AppTypography.fontSize12.copyWith(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${service.price.toStringAsFixed(2)} €',
                                    style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'incl. 20% VAT',
                                    style: AppTypography.fontSize10.copyWith(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () => _removeService(service),
                                child: Container(
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Empty state as a separate Sliver
            if (_selectedServices.isEmpty && _searchController.text.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 48.sp, color: Colors.grey.shade300),
                      SizedBox(height: 16.h),
                      Text(
                        'Search for services',
                        style: AppTypography.fontSize16.copyWith(color: Colors.grey.shade500),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Type in the search bar to find services',
                        style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      // Bottom Button
      bottomNavigationBar: _selectedServices.isNotEmpty && _searchController.text.isEmpty
          ? _buildBookingButton()
          : null,
    );
  }

  Widget _buildInfoDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Icon(Icons.question_mark_outlined, color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'To book a job you must add at least one service to your service list.',
                    style: AppTypography.fontSize14.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Use your desktop computer at\nhttps://my.repairmc.com/service',
              style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
                ),
                child: Text(
                  'Dismiss',
                  style: AppTypography.fontSize14.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    //final totalPrice = _selectedServices.fold(0.0, (sum, service) => sum + service.price);
    return Container(
      //padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 2, // Moves with keyboard
          left: 12.w,
          right: 12.w,
          top: 2,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_selectedServices.length} x Service selected',
                style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => JobBookingStartBookingJobScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                  ),
                  child: Text('Start booking', style: AppTypography.fontSize16Bold.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

class ServiceItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String duration;
  final String description;

  ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ServiceItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
