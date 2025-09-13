import 'package:repair_cms/core/app_exports.dart';

import 'one/job_booking_start_booking_job_screen.dart';

class JobBookingFirstScreen extends StatefulWidget {
  const JobBookingFirstScreen({super.key});

  @override
  State<JobBookingFirstScreen> createState() => _JobBookingFirstScreenState();
}

class _JobBookingFirstScreenState extends State<JobBookingFirstScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  void _toggleServiceSelection(ServiceItem service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _removeService(ServiceItem service) {
    setState(() {
      _selectedServices.remove(service);
    });
  }

  void _clearAllSelectedServices() {
    setState(() {
      _selectedServices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(Icons.close, color: Colors.black.withOpacity(0.7), size: 20.sp),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12.r)),
              child: Text(
                'Express Job',
                style: AppTypography.fontSize10.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedServices.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all, color: AppColors.primary),
              onPressed: _clearAllSelectedServices,
              tooltip: 'Clear all selections',
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Service Pricing',
                      style: AppTypography.fontSize38.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
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
                Text(
                  'List your service & book a job',
                  style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterServices,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        hintStyle: AppTypography.fontSize14.copyWith(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                        padding: EdgeInsets.only(right: 12.w),
                        child: Icon(Icons.close, color: Colors.grey.shade400, size: 20.sp),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Selected Services Section
          if (_selectedServices.isNotEmpty) _buildSelectedServices(),

          // Search Results (expanded to fill remaining space)
          Expanded(child: _buildContent()),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: _selectedServices.isNotEmpty ? _buildBookingButton() : null,
    );
  }

  Widget _buildContent() {
    if (_hasSearchResults) {
      return _buildSearchResults();
    } else if (_searchController.text.isNotEmpty && !_hasSearchResults) {
      return _buildNoResults();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        final isSelected = _selectedServices.contains(service);

        return GestureDetector(
          onTap: () => _toggleServiceSelection(service),
          onLongPress: () => _toggleServiceSelection(service),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Selection indicator
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade400),
                  ),
                  child: isSelected ? Icon(Icons.check, color: Colors.white, size: 16.sp) : null,
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: AppTypography.fontSize16Bold.copyWith(
                          color: isSelected ? AppColors.primary : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        service.category,
                        style: AppTypography.fontSize10.copyWith(color: isSelected ? AppColors.primary : Colors.blue),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${service.price.toStringAsFixed(2)} €',
                      style: AppTypography.fontSize16Bold.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'incl. 20% VAT',
                      style: AppTypography.fontSize10.copyWith(
                        color: isSelected ? AppColors.primary.withOpacity(0.7) : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedServices() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Services (${_selectedServices.length})',
                style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
              ),
              if (_selectedServices.isNotEmpty)
                GestureDetector(
                  onTap: _clearAllSelectedServices,
                  child: Text(
                    'Clear all',
                    style: AppTypography.fontSize12.copyWith(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          ..._selectedServices.map((service) => _buildSelectedServiceItem(service)),
        ],
      ),
    );
  }

  Widget _buildSelectedServiceItem(ServiceItem service) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: AppTypography.fontSize16Bold.copyWith(color: Colors.black)),
                      SizedBox(height: 2.h),
                      Text(service.category, style: AppTypography.fontSize10.copyWith(color: Colors.blue)),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${service.price.toStringAsFixed(2)} €',
                      style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
                    ),
                    SizedBox(height: 2.h),
                    Text('incl. 20% VAT', style: AppTypography.fontSize10.copyWith(color: Colors.grey.shade500)),
                  ],
                ),
                SizedBox(width: 8.w),
                Icon(Icons.done, color: Colors.green, size: 20.sp),
              ],
            ),
          ),
          Positioned(
            right: -6.w,
            top: -6.h,
            child: GestureDetector(
              onTap: () => _removeService(service),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.white, size: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Center(
        child: Text('No services found', style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade500)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('Search for services', style: AppTypography.fontSize16.copyWith(color: Colors.grey.shade500)),
          SizedBox(height: 8.h),
          Text(
            'Type in the search bar to find services',
            style: AppTypography.fontSize10.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Icon(Icons.info, color: Colors.white, size: 20.sp),
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
              style: AppTypography.fontSize10.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
    final totalPrice = _selectedServices.fold(0.0, (sum, service) => sum + service.price);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedServices.length} service${_selectedServices.length > 1 ? 's' : ''} selected',
                  style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600),
                ),
                Text(
                  'Total: ${totalPrice.toStringAsFixed(2)} €',
                  style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to booking details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting booking process with ${_selectedServices.length} services...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
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
