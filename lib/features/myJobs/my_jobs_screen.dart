import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/widgets/job_card_widget.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['My\nJobs', 'All\nJobs', 'Rejected\nQuotes', 'Completed\nJobs'];
  final List<int> _itemCounts = [365, 2, 2, 48];
  final List<Color> _tabColors = [Colors.grey, Colors.blue, Colors.red, Colors.green];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.search, color: Colors.black87),
        title: const Text(
          'My Jobs',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: const Color(0xFFD9E1EA),
            height: 60.h,
            padding: EdgeInsets.only(left: 12.w),
            child: Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tabTitles.length,
                separatorBuilder: (context, index) => Container(
                  width: 2.w,
                  height: 40.h, // 80% of the tab height (assuming tab height is 50)
                  color: Colors.grey.withValues(alpha: 0.3),
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                ),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 1.h, bottom: 1.h, left: 4.w, right: 4.w),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            height: 40.h,
                            width: 40.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: _tabColors[index]),
                            child: Text(
                              _itemCounts[index].toString(),
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          SizedBox(
                            child: Text(
                              _tabTitles[index],
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          Expanded(child: _buildJobList(_itemCounts[_selectedTabIndex])),
        ],
      ),
    );
  }

  Widget _buildJobList(int itemCount) {
    // Different job statuses for different tabs
    List<String> statuses;
    List<Color> statusColors;

    if (_selectedTabIndex == 0) {
      // My Jobs tab
      statuses = ['Booked In', 'In Progress', 'Pending'];
      statusColors = [Colors.blue, Colors.orange, Colors.blue];
    } else if (_selectedTabIndex == 1) {
      // All Jobs tab
      statuses = ['Scheduled', 'In Progress', 'Booked In'];
      statusColors = [Colors.purple, Colors.orange, Colors.blue];
    } else if (_selectedTabIndex == 2) {
      // Rejected Quotes tab
      statuses = ['Rejected', 'Cancelled'];
      statusColors = [Colors.red, Colors.redAccent];
    } else {
      // Completed Jobs tab
      statuses = ['Completed', 'Delivered'];
      statusColors = [Colors.green, Colors.greenAccent];
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16.r),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Cycle through statuses for variety
        final statusIndex = index % statuses.length;
        final priorityIndex = index % 3;

        final List<String> priorities = ['High', 'Medium', 'Neutral'];
        final List<Color> priorityColors = [Colors.red, Colors.orange, Colors.grey];

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: jobCardWidget(
            context: context,
            status: statuses[statusIndex],
            statusColor: statusColors[statusIndex],
            priority: priorities[priorityIndex],
            priorityColor: priorityColors[priorityIndex],
            jobId: (1048000 + index).toString(),
            date: '${(index % 30) + 1}.${(index % 12) + 1}.2025',
            warranty: index % 3 == 0 ? 'Warranty' : 'No Warranty',
            location: '${(index % 50) + 1}${String.fromCharCode(65 + (index % 26))}',
            deviceName: index % 3 == 0
                ? 'iPhone Xs 64GB Black'
                : index % 3 == 1
                ? 'Samsung Galaxy S10 128GB Blue'
                : 'Google Pixel 4 XL 64GB White',
            imei: 'IMEI/SN: 97430079${1000 + index}',
          ),
        );
      },
    );
  }
}
