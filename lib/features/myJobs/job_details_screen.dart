import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  int _selectedTabIndex = 0;
  int _selectedBottomIndex = 0;
  final List<String> _tabTitles = ['Job Details', 'Device Details'];

  bool isJobComplete = false;
  bool returnDevice = true;

  String selectedPriority = 'Neutral';
  String selectedDueDate = '14. March 2025';
  String selectedAssignee = 'Susan Lemmes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Peter Rankovic',
              style: GoogleFonts.roboto(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              'Auftrag-Nr: 5922001',
              style: GoogleFonts.roboto(color: Colors.grey.shade600, fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedBottomIndex) {
      case 0:
        return _buildJobDetailsScreen();
      case 1:
        return _buildReceiptsScreen();
      case 2:
        return _buildStatusScreen();
      case 3:
        return _buildNotesScreen();
      case 4:
        return _buildMoreScreen();
      default:
        return _buildJobDetailsScreen();
    }
  }

  Widget _buildJobDetailsScreen() {
    return Column(
      children: [
        // Toggle Switches Section
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Job Complete',
                    style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  CupertinoSwitch(
                    value: isJobComplete,
                    onChanged: (value) {
                      setState(() {
                        isJobComplete = value;
                      });
                    },
                    activeTrackColor: Colors.grey.shade400,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Return device',
                    style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  CupertinoSwitch(
                    value: returnDevice,
                    onChanged: (value) {
                      setState(() {
                        returnDevice = value;
                      });
                    },
                    activeTrackColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        // Tab Card (redesigned to match image)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildTabCard(),
        ),

        SizedBox(height: 16.h),

        // Content (Job Management etc)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Management Section (All dropdowns together)
                _buildInfoCard(
                  title: 'Job Management',
                  children: [
                    // Job Priority
                    Text(
                      'Job Priority',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildDropdownField(
                      icon: Icons.flag_outlined,
                      value: selectedPriority,
                      items: ['High', 'Medium', 'Neutral'],
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value!;
                        });
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Due Date
                    Text(
                      'Due Date',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildDropdownField(
                      icon: Icons.calendar_today_outlined,
                      value: selectedDueDate,
                      items: ['14. March 2025', '15. March 2025', '16. March 2025'],
                      onChanged: (value) {
                        setState(() {
                          selectedDueDate = value!;
                        });
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Assignee
                    Text(
                      'Assignee',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildDropdownField(
                      icon: Icons.person_outline,
                      value: selectedAssignee,
                      items: ['Susan Lemmes', 'John Doe', 'Jane Smith'],
                      onChanged: (value) {
                        setState(() {
                          selectedAssignee = value!;
                        });
                      },
                      hasAvatar: true,
                    ),
                  ],
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // New single card that contains tabs and the content styled like the provided image
  Widget _buildTabCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Tabs row inside the card
          Row(
            children: _tabTitles.asMap().entries.map((entry) {
              final int index = entry.key;
              final String title = entry.value;
              final bool isSelected = _selectedTabIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(index == 0 ? 12.r : 0),
                        topRight: Radius.circular(index == _tabTitles.length - 1 ? 12.r : 0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.blue : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // underline
                        Container(
                          height: 3.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          // Content area matching the image: labels bold, values lighter and below
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: _selectedTabIndex == 0 ? _jobDetailsCardContent() : _deviceDetailsCardContent(),
          ),
        ],
      ),
    );
  }

  Widget _jobDetailsCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardInfoRow('Physical location:', '15D'),
        SizedBox(height: 12.h),
        _buildCardInfoRow('Defect type:', 'LCD-Broken'),
        SizedBox(height: 12.h),
        _buildCardInfoSection('Problem Description:', 'Please check LCD & send quote customer in mail'),
      ],
    );
  }

  Widget _deviceDetailsCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardInfoRow('Device:', 'iPhone Xs 64GB Black'),
        SizedBox(height: 12.h),
        _buildCardInfoRow('IMEI/SN:', '974300791048'),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Show Device Security',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
              color: Colors.blue,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // New stylings that match the reference image
  Widget _buildCardInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A4A67), // slightly muted blue/gray like the reference
          ),
        ),
        SizedBox(width: 6.h),
        Text(
          value,
          style: GoogleFonts.roboto(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildCardInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Color(0xFF3A4A67)),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptsScreen() {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Text(
            'Receipts & Documents',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildReceiptItem('Invoice #5922001-01', 'March 14, 2025', '€89.99', Icons.receipt_long, Colors.blue),
              SizedBox(height: 12.h),
              _buildReceiptItem('Quote #5922001-QT', 'March 12, 2025', '€89.99', Icons.request_quote, Colors.orange),
              SizedBox(height: 12.h),
              _buildReceiptItem('Diagnostic Report', 'March 12, 2025', 'PDF', Icons.description, Colors.green),
              SizedBox(height: 12.h),
              _buildReceiptItem(
                'Customer Authorization',
                'March 12, 2025',
                'Signed',
                Icons.verified_user,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusScreen() {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Text(
            'Job Status Timeline',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildStatusItem(
                'Job Created',
                'March 12, 2025 - 09:30 AM',
                'Job created by reception',
                true,
                Colors.blue,
              ),
              _buildStatusItem(
                'Initial Diagnosis',
                'March 12, 2025 - 11:15 AM',
                'LCD damage confirmed, quote sent to customer',
                true,
                Colors.orange,
              ),
              _buildStatusItem(
                'Quote Approved',
                'March 12, 2025 - 02:45 PM',
                'Customer approved repair quote via email',
                true,
                Colors.green,
              ),
              _buildStatusItem(
                'Parts Ordered',
                'March 13, 2025 - 08:20 AM',
                'LCD screen ordered from supplier',
                true,
                Colors.purple,
              ),
              _buildStatusItem(
                'Repair in Progress',
                'March 14, 2025 - 10:00 AM',
                'Assigned to Susan Lemmes',
                false,
                Colors.blue,
              ),
              _buildStatusItem('Quality Check', 'Pending', 'Waiting for repair completion', false, Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesScreen() {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Notes',
                style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              IconButton(
                onPressed: () {
                  // Add new note functionality
                },
                icon: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildNoteItem(
                'Initial Assessment',
                'Customer reported that screen went black after dropping phone. Visible crack on LCD. Touch functionality completely lost. Battery seems to be working fine as phone vibrates on calls.',
                'John Doe',
                'March 12, 2025 - 11:30 AM',
              ),
              SizedBox(height: 16.h),
              _buildNoteItem(
                'Customer Communication',
                'Contacted customer via phone. Explained repair process and timeline. Customer confirmed they want to proceed with repair. Backup of data not needed as they sync with iCloud.',
                'Reception',
                'March 12, 2025 - 02:15 PM',
              ),
              SizedBox(height: 16.h),
              _buildNoteItem(
                'Parts Update',
                'LCD screen in stock. High quality aftermarket part available. Estimated repair time: 2-3 hours once started.',
                'Susan Lemmes',
                'March 14, 2025 - 09:45 AM',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreScreen() {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Text(
            'More Options',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildMoreOption(Icons.photo_camera, 'Take Photos', 'Capture device condition photos', Colors.blue),
              _buildMoreOption(Icons.share, 'Share Job', 'Send job details to customer or team', Colors.green),
              _buildMoreOption(Icons.print, 'Print Labels', 'Print job and device labels', Colors.orange),
              _buildMoreOption(Icons.history, 'Job History', 'View complete job timeline', Colors.purple),
              _buildMoreOption(Icons.attach_money, 'Update Pricing', 'Modify quotes and billing', Colors.teal),
              _buildMoreOption(Icons.person_add, 'Reassign Job', 'Change job assignee', Colors.indigo),
              _buildMoreOption(Icons.priority_high, 'Change Priority', 'Update job priority level', Colors.red),
              _buildMoreOption(Icons.settings, 'Job Settings', 'Configure job preferences', Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptItem(String title, String date, String amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, String time, String description, bool isCompleted, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(color: isCompleted ? color : Colors.grey.shade300, shape: BoxShape.circle),
              child: isCompleted ? Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            if (title != 'Quality Check')
              Container(
                width: 2.w,
                height: 40.h,
                color: Colors.grey.shade300,
                margin: EdgeInsets.symmetric(vertical: 8.h),
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.r),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: GoogleFonts.roboto(fontSize: 12.sp, color: color, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteItem(String title, String content, String author, String time) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Icon(Icons.more_vert, color: Colors.grey.shade400),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.black87, height: 1.4),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade500),
              SizedBox(width: 4.w),
              Text(
                author,
                style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
              SizedBox(width: 4.w),
              Text(
                time,
                style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOption(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // Handle option tap
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title tapped')));
          },
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children, String? title}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...children]),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool hasAvatar = false,
  }) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (hasAvatar) ...[
                    CircleAvatar(
                      radius: 12.r,
                      backgroundColor: Colors.green,
                      child: Text(
                        item.split(' ').map((word) => word[0]).join(),
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ] else ...[
                    Icon(icon, color: Colors.blue, size: 20),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80.h,
      color: const Color(0xFF1E3A5F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.description_outlined, 'Job Details', 0),
          _buildNavItem(Icons.receipt_outlined, 'Receipt´s', 1),
          _buildNavItem(Icons.access_time, 'Status', 2),
          _buildNavItem(Icons.notes_outlined, 'Notes', 3),
          _buildNavItem(Icons.more_horiz, 'More', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade400, size: 24),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 10.sp,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
