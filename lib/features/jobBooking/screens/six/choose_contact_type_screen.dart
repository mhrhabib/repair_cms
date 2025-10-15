import 'dart:async';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/seven/job_booking_address_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';

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

  List<Customersorsuppliers> companySearchResults = [];
  bool showCompanyResults = false;
  bool showContactForm = false;
  bool showNewCompanyOption = false;
  String currentSearchQuery = '';
  bool isExistingCompanySelected = false;
  Timer? _searchDebounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    companyController.addListener(_onCompanySearchChanged);
  }

  void _onCompanySearchChanged() {
    final query = companyController.text.trim();
    currentSearchQuery = query;

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        companySearchResults = [];
        showCompanyResults = false;
        showNewCompanyOption = false;
        isExistingCompanySelected = false;
        _isSearching = false;
      });
      return;
    }

    // Show results container immediately
    setState(() {
      showCompanyResults = true;
      _isSearching = true;
    });

    // Debounce search to avoid too many API calls
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final context = this.context;
    if (context.mounted) {
      // Call the API search
      context.read<ContactTypeCubit>().searchBusinessesApi(userId: _getUserId(), query: query, limit: 5);
    }
  }

  String _getUserId() {
    return storage.read('userId') ?? '';
  }

  void _selectCompany(Customersorsuppliers business) {
    setState(() {
      companyController.text = business.organization ?? '${business.firstName} ${business.lastName}';
      showCompanyResults = false;
      showNewCompanyOption = false;
      showContactForm = false;
      isExistingCompanySelected = true;
      _isSearching = false;
    });

    // Save selected business to JobBookingCubit
    _saveBusinessToJobBooking(business);
  }

  void _selectNewCompany() {
    setState(() {
      companyController.text = currentSearchQuery;
      showCompanyResults = false;
      showNewCompanyOption = false;
      showContactForm = true;
      isExistingCompanySelected = false;
      _isSearching = false;
    });
  }

  void _saveBusinessToJobBooking(Customersorsuppliers business) {
    final jobBookingCubit = context.read<JobBookingCubit>();

    // Get primary contact details
    final primaryPhone = context.read<ContactTypeCubit>().getPrimaryPhoneNumber(business);
    final primaryEmail = context.read<ContactTypeCubit>().getPrimaryEmail(business);

    // Update job booking with business information
    jobBookingCubit.updateContactType(
      type: "Business",
      type2: "business",
      organization: business.organization,
      customerNo: business.customerNumber,
      position: business.position,
    );

    jobBookingCubit.updateCustomerInfo(
      salutation: business.supplierName,
      firstName: business.firstName,
      lastName: business.lastName,
      telephone: primaryPhone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '', // Clean phone number
      telephonePrefix: _extractPhonePrefix(primaryPhone),
      customerId: business.sId,
    );
  }

  String? _extractPhonePrefix(String? phone) {
    if (phone == null) return "+1";
    final match = RegExp(r'^(\+\d+)').firstMatch(phone);
    return match?.group(1) ?? "+1";
  }

  void _createNewBusiness() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    final contactTypeCubit = context.read<ContactTypeCubit>();
    final jobBookingCubit = context.read<JobBookingCubit>();

    // Create payload for new business
    final payload = contactTypeCubit.createBusinessPayload(
      type: "Business",
      type2: "business",
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      organization: companyController.text,
      position: "Customer", // Default position
      userId: _getUserId(),
      location: "default_location_id", // You might want to get this from user data
      telephones: [
        {
          "number": phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
          "phone_prefix": "+1", // You might want to make this dynamic
          "type": "Private",
        },
      ],
      emails: [
        {"email": emailController.text, "type": "Private"},
      ],
    );

    // Create the business
    contactTypeCubit.createBusiness(payload: payload).then((_) {
      // After creation, the business will be added to the list automatically
      // We can navigate to next screen
      _navigateToNextScreen();
    });
  }

  void _handlePersonalContact() {
    final jobBookingCubit = context.read<JobBookingCubit>();

    // Update job booking for personal contact
    jobBookingCubit.updateContactType(
      type: "Personal",
      type2: "personal",
      organization: "",
      customerNo: "",
      position: "",
    );

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const JobBookingAddressScreen()));
  }

  bool get _shouldShowButton {
    return selectedContactType == 'personal' || isExistingCompanySelected || showContactForm;
  }

  bool get _isFormValid {
    if (showContactForm) {
      return firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty;
    }
    return true;
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
                width: double.infinity,
                color: Colors.grey[300],
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071 * 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                    ),
                  ),
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

                        // Company search results from API
                        if (showCompanyResults && currentSearchQuery.isNotEmpty) ...[
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
                            child: BlocBuilder<ContactTypeCubit, ContactTypeState>(
                              builder: (context, state) {
                                // Show loading while searching
                                if (_isSearching && state is! ContactTypeSearchResult) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                // Show search results
                                if (state is ContactTypeSearchResult) {
                                  companySearchResults = state.businesses;

                                  // Check if we should show "NEW" option
                                  final hasExactMatch = companySearchResults.any(
                                    (business) =>
                                        business.organization?.toLowerCase() == currentSearchQuery.toLowerCase() ||
                                        '${business.firstName ?? ''} ${business.lastName ?? ''}'.trim().toLowerCase() ==
                                            currentSearchQuery.toLowerCase(),
                                  );

                                  final shouldShowNewOption = currentSearchQuery.isNotEmpty && !hasExactMatch;

                                  return Column(
                                    children: [
                                      // NEW company option (shown first)
                                      if (shouldShowNewOption) ...[
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

                                      // Existing company results from API
                                      if (companySearchResults.isNotEmpty) ...[
                                        ...companySearchResults.map((business) {
                                          final companyName =
                                              business.organization ??
                                              '${business.firstName ?? ''} ${business.lastName ?? ''}'.trim();
                                          final phone = context.read<ContactTypeCubit>().getPrimaryPhoneNumber(
                                            business,
                                          );

                                          return GestureDetector(
                                            onTap: () => _selectCompany(business),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                border:
                                                    companySearchResults.indexOf(business) !=
                                                        companySearchResults.length - 1
                                                    ? Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))
                                                    : null,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    companyName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (phone != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      phone,
                                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],

                                      // Show message if no results and no new option
                                      if (companySearchResults.isEmpty && !shouldShowNewOption) ...[
                                        const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text('No businesses found', style: TextStyle(color: Colors.grey)),
                                        ),
                                      ],
                                    ],
                                  );
                                }

                                // Show error state
                                if (state is ContactTypeError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Search failed: ${state.message}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }

                                // Default empty state
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ],
                    ],

                    // Contact form (shown only for new companies)
                    if (showContactForm) ...[
                      // ... (rest of the contact form remains the same)
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
                  onPressed: _isFormValid
                      ? () {
                          if (selectedContactType == 'personal') {
                            _handlePersonalContact();
                          } else if (isExistingCompanySelected) {
                            _navigateToNextScreen();
                          } else if (showContactForm) {
                            _createNewBusiness();
                          }
                        }
                      : null,
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
    _searchDebounceTimer?.cancel();
    companyController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
