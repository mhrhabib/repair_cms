import 'package:flutter/material.dart';

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
        child: Column(
          children: [
            // Progress bar
            Container(
              height: 4,
              width: double.infinity,
              color: Colors.grey[300],
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(height: 4, width: MediaQuery.of(context).size.width * 0.9, color: Colors.blue),
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
                  '9',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title and subtitle
            const Text(
              'Problem Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),

            const SizedBox(height: 8),

            Text('(Describe the defect and issue)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),

            const SizedBox(height: 32),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Problem Description field
                    TextField(
                      controller: _problemDescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe problem',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    // Internal Note field
                    TextField(
                      controller: _internalNoteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Internal note',
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
                              if (_problemDescriptionController.text.isNotEmpty) {
                                // Process the problem description and internal note
                                Navigator.pop(context);
                              } else {
                                // Show error or validation message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please describe the problem'),
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
    _problemDescriptionController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }
}
