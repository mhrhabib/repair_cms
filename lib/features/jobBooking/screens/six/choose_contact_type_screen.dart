import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Track keyboard visibility
  bool _isKeyboardVisible = false;

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

    // Add listeners to track keyboard visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardListeners();
    });
  }

  void _setupKeyboardListeners() {
    final viewInsets = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets,
      WidgetsBinding.instance.window.devicePixelRatio,
    );

    _isKeyboardVisible = viewInsets.bottom > 0;

    // Listen for changes in keyboard visibility
    WidgetsBinding.instance.window.onMetricsChanged = () {
      final newViewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio,
      );

      final newKeyboardVisible = newViewInsets.bottom > 0;

      if (newKeyboardVisible != _isKeyboardVisible) {
        setState(() {
          _isKeyboardVisible = newKeyboardVisible;
        });
      }
    };
  }

  void _onCompanySearchChanged() {
    final query = companyController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        companySearchResults = [];
        showCompanyResults = false;
      });
      return;
    }

    setState(() {
      companySearchResults = allCompanies.where((company) => company.toLowerCase().contains(query)).take(3).toList();
      showCompanyResults = companySearchResults.isNotEmpty;
    });
  }

  void _selectCompany(String company) {
    setState(() {
      companyController.text = company;
      showCompanyResults = false;
      showContactForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Progress bar
                Container(
                  height: 4,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(height: 4, width: MediaQuery.of(context).size.width * 0.6, color: Colors.blue),
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
                      '6',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                if (!showContactForm) ...[
                  const Text(
                    'Choose the contact type',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                ],

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!showContactForm) ...[
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
                                  children: companySearchResults.map((company) {
                                    return GestureDetector(
                                      onTap: () => _selectCompany(company),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border:
                                              companySearchResults.indexOf(company) != companySearchResults.length - 1
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
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ],

                        // Contact form (shown after company selection)
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
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
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
                        ],

                        // Add extra space at the bottom when keyboard is visible
                        if (_isKeyboardVisible) SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // OK Button positioned above keyboard
            if (_isKeyboardVisible || showContactForm)
              Positioned(
                left: 24,
                right: 24,
                bottom: bottomPadding > 0 ? bottomPadding + 16 : 32,
                child: Container(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle form submission
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 2,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
