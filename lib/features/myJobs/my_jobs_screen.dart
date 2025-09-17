import 'package:flutter/material.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          // Tab Bar Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem('365', 'My Jobs', true, Colors.grey),
                  const SizedBox(width: 8),
                  _buildTabItem('2', 'All Jobs', false, Colors.blue),
                  const SizedBox(width: 8),
                  _buildTabItem('2', 'Rejected Quotes', false, Colors.red),
                  const SizedBox(width: 8),
                  _buildTabItem('', '', false, Colors.green),
                ],
              ),
            ),
          ),

          // Jobs List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Booked In Job
                _buildJobCard(
                  status: 'Booked In',
                  statusColor: Colors.blue,
                  priority: 'High',
                  priorityColor: Colors.red,
                  jobId: '1048010',
                  date: '05.12.2025',
                  warranty: 'Warranty',
                  location: '14C',
                  deviceName: 'iPhone Xs 64GB Black',
                  imei: 'IMEI/SN: 974300790813',
                ),

                const SizedBox(height: 16),

                // In Progress Job
                _buildJobCard(
                  status: 'In Progress',
                  statusColor: Colors.orange,
                  priority: 'Medium',
                  priorityColor: Colors.orange,
                  jobId: '1048011',
                  date: '06.15.2025',
                  warranty: 'Warranty',
                  location: '22B',
                  deviceName: 'Samsung Galaxy S10 128GB Blue',
                  imei: 'IMEI/SN: 974300790814',
                ),

                const SizedBox(height: 16),

                // Pending Job
                _buildJobCard(
                  status: 'Pending',
                  statusColor: Colors.blue,
                  priority: 'Neutral',
                  priorityColor: Colors.grey,
                  jobId: '1048012',
                  date: '07.20.2025',
                  warranty: 'Warranty',
                  location: '33A',
                  deviceName: 'Google Pixel 4 XL 64GB White',
                  imei: 'IMEI/SN: 974300790815',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String number, String label, bool isSelected, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade200 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.grey.shade300 : Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (number.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          if (number.isNotEmpty && label.isNotEmpty) const SizedBox(width: 8),
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobCard({
    required String status,
    required Color statusColor,
    required String priority,
    required Color priorityColor,
    required String jobId,
    required String date,
    required String warranty,
    required String location,
    required String deviceName,
    required String imei,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Priority Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    const Text('Priority:', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      priority,
                      style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Job Details
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job ID: $jobId',
                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$date | $warranty | Location: $location',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        deviceName,
                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(imei, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
