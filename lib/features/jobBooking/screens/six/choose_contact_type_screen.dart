import 'package:flutter/material.dart';
import 'package:repair_cms/features/jobBooking/screens/seven/job_booking_address_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class ChooseContactTypeScreen extends StatefulWidget {
  const ChooseContactTypeScreen({super.key});

  @override
  State<ChooseContactTypeScreen> createState() => _ChooseContactTypeScreenState();
}

class _ChooseContactTypeScreenState extends State<ChooseContactTypeScreen> {
  String selectedContactType = '';
  final TextEditingController companyController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<String> companySearchResults = [];
  bool showCompanyResults = false;
  bool showContactForm = false;
  bool showNewCompanyOption = false;
  String currentSearchQuery = '';
  bool isExistingCompanySelected = false; // NEW: Track if existing company was selected

  // Sample company data for search
  final List<String> allCompanies = [
    'Bi Mobile Limited',
    'Big Mobile Limited',
    'Big Narrow Limited',
    'Business Corp',
    'Best Solutions Ltd',
  ];

  @override
  void initState() {
    super.initState();
    companyController.addListener(_onCompanySearchChanged);
  }

  void _onCompanySearchChanged() {
    final query = companyController.text.trim();
    currentSearchQuery = query;

    if (query.isEmpty) {
      setState(() {
        companySearchResults = [];
        showCompanyResults = false;
        showNewCompanyOption = false;
        isExistingCompanySelected = false; // Reset when query is empty
      });
      return;
    }

    final exactMatch = allCompanies.any((company) => company.toLowerCase() == query.toLowerCase());

    setState(() {
      // Show search results from existing companies
      companySearchResults = allCompanies
          .where((company) => company.toLowerCase().contains(query.toLowerCase()))
          .take(3)
          .toList();

      // Show "NEW" option if the query doesn't exactly match any existing company
      showNewCompanyOption = query.isNotEmpty && !exactMatch;
      showCompanyResults = companySearchResults.isNotEmpty || showNewCompanyOption;
    });
  }

  void _selectCompany(String company) {
    setState(() {
      companyController.text = company;
      showCompanyResults = false;
      showNewCompanyOption = false;
      showContactForm = false; // CHANGED: Don't show contact form for existing companies
      isExistingCompanySelected = true; // NEW: Mark as existing company selected
    });
  }

  void _selectNewCompany() {
    setState(() {
      companyController.text = currentSearchQuery;
      showCompanyResults = false;
      showNewCompanyOption = false;
      showContactForm = true; // Keep showing contact form for new companies
      isExistingCompanySelected = false; // NEW: Mark as not an existing company
    });
  }

  bool get _shouldShowButton {
    // CHANGED: Show button for personal, existing company selection, or contact form
    return selectedContactType == 'personal' || isExistingCompanySelected || showContactForm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
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
                  child: Container(height: 4, width: MediaQuery.of(context).size.width * 0.6, color: Colors.blue),
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
                      '6',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            // Title
            if (!showContactForm && !isExistingCompanySelected) ...[
              // CHANGED: Condition
              SliverToBoxAdapter(
                child: const Center(
                  child: Text(
                    'Choose the contact type',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),
            ],

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showContactForm && !isExistingCompanySelected) ...[
                      // CHANGED: Condition
                      // Contact type options
                      _buildContactTypeOption(
                        icon: Icons.person_outline,
                        title: 'Personal',
                        isSelected: selectedContactType == 'personal',
                        onTap: () => setState(() => selectedContactType = 'personal'),
                      ),

                      const SizedBox(height: 16),

                      _buildContactTypeOption(
                        icon: Icons.business_outlined,
                        title: 'Business',
                        isSelected: selectedContactType == 'business',
                        onTap: () => setState(() => selectedContactType = 'business'),
                      ),

                      const SizedBox(height: 32),

                      // Company search field (only show when business is selected)
                      if (selectedContactType == 'business') ...[
                        const Text(
                          'Company',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: companyController,
                          decoration: InputDecoration(
                            hintText: 'Company name',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),

                        // Company search results
                        if (showCompanyResults) ...[
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // NEW company option (shown first)
                                if (showNewCompanyOption) ...[
                                  GestureDetector(
                                    onTap: _selectNewCompany,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              currentSearchQuery,
                                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'NEW',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                // Existing company results
                                ...companySearchResults.map((company) {
                                  return GestureDetector(
                                    onTap: () => _selectCompany(company),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: companySearchResults.indexOf(company) != companySearchResults.length - 1
                                            ? Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))
                                            : null,
                                      ),
                                      child: Text(
                                        company,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: company.toLowerCase().contains('narrow')
                                              ? Colors.orange[700]
                                              : Colors.black87,
                                          fontWeight: company.toLowerCase().contains('narrow')
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],

                    // Contact form (shown only for new companies)
                    if (showContactForm) ...[
                      // Company name (readonly)
                      const Text(
                        'Company name',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: companyController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),

                      const SizedBox(height: 24),

                      // Contact Person section
                      const Text(
                        'Contact Person',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),

                      // First Name
                      const Text('First Name*', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          hintText: 'John',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Last Name
                      const Text('Last Name*', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Markinson',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      const Text('Email*', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'name@company.com',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Telephone
                      const Text('Telephone (Mobile)*', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 12,
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: '+880-1712345678',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Add extra space at the bottom for the button
                      const SizedBox(height: 80),
                    ],

                    // Show confirmation when existing company is selected
                    if (isExistingCompanySelected) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Selected: ${companyController.text}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'You can proceed to the next step',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],

                    // Add extra space when personal is selected but form not shown
                    if (selectedContactType == 'personal' && !showContactForm && !isExistingCompanySelected) ...[
                      const SizedBox(height: 80),
                    ],
                  ],
                ),
              ),
            ),

            // Add extra space at the bottom for the button
            if (_shouldShowButton) const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8, left: 24, right: 24),
        child: _shouldShowButton
            ? SizedBox(
                height: 48,
                child: BottomButtonsGroup(
                  onPressed: () {
                    // Handle form submission
                    if (selectedContactType == 'personal') {
                      // Navigate to next screen for personal contact
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const JobBookingAddressScreen()));
                    } else if (isExistingCompanySelected) {
                      // Navigate to next screen for existing company
                      print('Existing company selected: ${companyController.text}');
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const JobBookingAddressScreen()));
                    } else if (showContactForm) {
                      // Validate and submit business contact form for new company
                      print('New company contact form submitted: ${companyController.text}');
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const JobBookingAddressScreen()));
                    }
                  },
                ),
              )
            : const SizedBox(height: 0),
      ),
    );
  }

  Widget _buildContactTypeOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.blue : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    companyController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
