import 'package:flutter/material.dart';
import 'package:repair_cms/features/jobBooking/screens/ten/job_booking_add_items_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingProblemDescriptionScreen extends StatefulWidget {
  const JobBookingProblemDescriptionScreen({super.key});

  @override
  State<JobBookingProblemDescriptionScreen> createState() => _JobBookingProblemDescriptionScreenState();
}

class _JobBookingProblemDescriptionScreenState extends State<JobBookingProblemDescriptionScreen> {
  final TextEditingController _problemDescriptionController = TextEditingController();
  final TextEditingController _internalNoteController = TextEditingController();

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
                  child: Container(height: 4, width: MediaQuery.of(context).size.width * 0.9, color: Colors.blue),
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
                      '9',
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
                    'Problem Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text('(Describe the defect and issue)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 32)),

            // Form content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Problem Description field
                    const Text(
                      'Problem Description*',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _problemDescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe the problem in detail',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 24),

                    // Internal Note field
                    const Text(
                      'Internal Note',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _internalNoteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add internal notes (optional)',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    // Navigation buttons
                    const SizedBox(height: 100), // Extra space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8, left: 24, right: 24),
        child: BottomButtonsGroup(
          onPressed: () {
            // Handle form submission
            if (_problemDescriptionController.text.isNotEmpty) {
              // Process the problem description and internal note
              Navigator.push(context, MaterialPageRoute(builder: (context) => const JobBookingAddItemsScreen()));
            } else {
              // Show error or validation message
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Please describe the problem'), backgroundColor: Colors.red));
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _problemDescriptionController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }
}
