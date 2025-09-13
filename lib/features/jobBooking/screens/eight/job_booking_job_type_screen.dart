import 'package:flutter/material.dart';

class JobBookingJobTypeScreen extends StatefulWidget {
  const JobBookingJobTypeScreen({super.key});

  @override
  State<JobBookingJobTypeScreen> createState() => _JobBookingJobTypeScreenState();
}

class _JobBookingJobTypeScreenState extends State<JobBookingJobTypeScreen> {
  final TextEditingController _referenceController = TextEditingController();
  String? selectedJobType;

  final List<String> jobTypes = ['Warranty', 'ReRepair', 'Quote request', 'Installation', 'Maintenance', 'Inspection'];

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
                child: Container(height: 4, width: MediaQuery.of(context).size.width * 0.8, color: Colors.blue),
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
                  '8',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title and subtitle
            const Text(
              'Job Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),

            const SizedBox(height: 8),

            Text('(Warranty, ReRepair, Quote req...)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),

            const SizedBox(height: 32),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Type Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedJobType,
                          hint: Text('Answer here', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                          items: jobTypes.map((String jobType) {
                            return DropdownMenuItem<String>(value: jobType, child: Text(jobType));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedJobType = newValue;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reference field
                    const Text(
                      'Reference',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _referenceController,
                      decoration: InputDecoration(
                        hintText: 'Enter reference',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),

                    const Spacer(),

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
                              // Handle form submission
                              if (selectedJobType != null) {
                                // Process the selected job type and reference
                                Navigator.pop(context);
                              } else {
                                // Show error or validation message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a job type'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }
}
