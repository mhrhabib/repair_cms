import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/screens/nine/job_booking_problem_description_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/core/app_exports.dart';

class JobBookingJobTypeScreen extends StatefulWidget {
  const JobBookingJobTypeScreen({super.key});

  @override
  State<JobBookingJobTypeScreen> createState() => _JobBookingJobTypeScreenState();
}

class _JobBookingJobTypeScreenState extends State<JobBookingJobTypeScreen> {
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String? selectedJobType;

  final List<String> jobTypes = ['Warranty', 'ReRepair', 'Quote request', 'Installation', 'Maintenance', 'Inspection'];

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
                  child: Container(height: 4, width: MediaQuery.of(context).size.width * 0.8, color: Colors.blue),
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
                      '8',
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
                    'Job Type',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text('(Warranty, ReRepair, Quote req...)', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                    // Job Type Dropdown (Custom Search)
                    CustomDropdownSearch<String>(
                      controller: _jobTypeController,
                      items: jobTypes,
                      hintText: 'Answer here',
                      noItemsText: 'No job types found',
                      onSuggestionSelected: (String jobType) {
                        setState(() {
                          selectedJobType = jobType;
                          _jobTypeController.text = jobType;
                        });
                      },
                      itemBuilder: (BuildContext context, String jobType) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          child: Text(
                            jobType,
                            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                          ),
                        );
                      },
                      suggestionsCallback: (String pattern) {
                        return jobTypes
                            .where((jobType) => jobType.toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                      },
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                      maxHeight: 200.h,
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

                    const SizedBox(height: 32),

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
            if (selectedJobType != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobBookingProblemDescriptionScreen()),
              );
            } else {
              // Show error or validation message
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Please select a job type'), backgroundColor: Colors.red));
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jobTypeController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
