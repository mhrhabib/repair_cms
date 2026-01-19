import 'dart:async';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
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
  final TextEditingController searchController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  List<Customersorsuppliers> searchResults = [];
  bool showSearchResults = false;
  bool showContactForm = false;
  bool showNewOption = false;
  String currentSearchQuery = '';
  bool isExistingProfileSelected = false;
  Customersorsuppliers? selectedProfile;
  Timer? _searchDebounceTimer;
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    currentSearchQuery = query;

    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showSearchResults = false;
        showNewOption = false;
        isExistingProfileSelected = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      showSearchResults = true;
      _isSearching = true;
    });

    // Scroll to show search results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final context = this.context;
    if (context.mounted) {
      context
          .read<ContactTypeCubit>()
          .searchProfilesApi(userId: _getUserId(), query: query, type2: selectedContactType, limit: 5)
          .then((_) {
            if (mounted) {
              setState(() {
                _isSearching = false;
              });
            }
          });
    }
  }

  String _getUserId() {
    return storage.read('userId') ?? '';
  }

  void _selectProfile(Customersorsuppliers profile) {
    setState(() {
      final displayName = profile.organization ?? '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
      searchController.text = displayName;
      showSearchResults = false;
      showNewOption = false;
      showContactForm = false;
      isExistingProfileSelected = true;
      selectedProfile = profile;
      _isSearching = false;
    });

    _saveProfileToJobBooking(profile);

    // Immediately navigate to next screen when existing profile is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextScreen();
    });
  }

  void _selectNewProfile() {
    setState(() {
      if (selectedContactType == 'business') {
        organizationController.text = currentSearchQuery;
      } else {
        // For personal, parse the name
        final nameParts = currentSearchQuery.split(' ');
        if (nameParts.isNotEmpty) {
          firstNameController.text = nameParts.first;
          if (nameParts.length > 1) {
            lastNameController.text = nameParts.sublist(1).join(' ');
          }
        }
      }
      showSearchResults = false;
      showNewOption = false;
      showContactForm = true;
      isExistingProfileSelected = false;
      _isSearching = false;
    });
  }

  void _saveProfileToJobBooking(Customersorsuppliers profile) {
    final jobBookingCubit = context.read<JobBookingCubit>();
    final contactTypeCubit = context.read<ContactTypeCubit>();

    final primaryPhone = contactTypeCubit.getPrimaryPhoneNumber(profile);
    final primaryEmail = contactTypeCubit.getPrimaryEmail(profile);

    // Update contact type
    jobBookingCubit.updateContactType(
      type: selectedContactType == 'business' ? "Business" : "Personal",
      type2: selectedContactType,
      organization: profile.organization ?? '',
      customerNo: profile.customerNumber ?? '',
      position: profile.position ?? '',
    );

    // Update customer info
    jobBookingCubit.updateCustomerInfo(
      salutation: profile.supplierName ?? '',
      firstName: profile.firstName ?? '',
      lastName: profile.lastName ?? '',
      telephone: primaryPhone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '',
      telephonePrefix: _extractPhonePrefix(primaryPhone),
      email: primaryEmail ?? '',
      customerId: profile.sId ?? '',
    );

    // Check if profile has complete address and update if available
    final shippingAddress = contactTypeCubit.getPrimaryShippingAddress(profile);
    if (_hasCompleteAddress(shippingAddress)) {
      // Update shipping address in JobBooking
      jobBookingCubit.updateShippingAddress(
        CustomerAddress(
          id: shippingAddress?.sId ?? '',
          street: shippingAddress?.street ?? '',
          no: shippingAddress?.iV?.toString() ?? '',
          city: shippingAddress?.city ?? '',
          zip: shippingAddress?.zip ?? '',
          country: shippingAddress?.country ?? '',
          state: shippingAddress?.city ?? shippingAddress?.city ?? '',
        ),
      );

      // Also update billing address
      jobBookingCubit.updateBillingAddress(
        CustomerAddress(
          id: shippingAddress?.sId ?? '',
          street: shippingAddress?.street ?? '',
          no: shippingAddress?.iV?.toString() ?? '',
          city: shippingAddress?.city ?? '',
          zip: shippingAddress?.zip ?? '',
          country: shippingAddress?.country ?? '',
          state: shippingAddress?.city ?? shippingAddress?.city ?? '',
        ),
      );
    }
  }

  void _saveNewProfileToJobBooking() {
    final jobBookingCubit = context.read<JobBookingCubit>();

    // Update contact type
    jobBookingCubit.updateContactType(
      type: selectedContactType == 'business' ? "Business" : "Personal",
      type2: selectedContactType,
      organization: selectedContactType == 'business' ? organizationController.text : '',
      customerNo: '', // Will be generated by backend
      position: selectedContactType == 'business' ? "Customer" : '',
    );

    // Update customer info
    jobBookingCubit.updateCustomerInfo(
      salutation: '',
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      telephone: phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
      telephonePrefix: "+1", // Default prefix
      email: emailController.text,
      customerId: '', // Will be set after profile creation
    );
  }

  bool _hasCompleteAddress(ShippingAddresses? address) {
    if (address == null) return false;
    return (address.street?.isNotEmpty ?? false) &&
        ((address.iV?.toString().isNotEmpty ?? false)) &&
        (address.city?.isNotEmpty ?? false) &&
        (address.zip?.isNotEmpty ?? false);
  }

  String? _extractPhonePrefix(String? phone) {
    if (phone == null) return "+1";
    final match = RegExp(r'^(\+\d+)').firstMatch(phone);
    return match?.group(1) ?? "+1";
  }

  void _navigateToNextScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            JobBookingAddressScreen(isNewProfile: !isExistingProfileSelected, selectedProfile: selectedProfile),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  bool get _shouldShowButton {
    // Only show button for new profiles, not for existing ones
    return !isExistingProfileSelected && showContactForm && _isFormValid;
  }

  bool get _isFormValid {
    if (showContactForm) {
      final basicFieldsValid = firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty;

      if (selectedContactType == 'business') {
        return basicFieldsValid && organizationController.text.isNotEmpty;
      }
      return basicFieldsValid;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
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
                      onTap: () => Navigator.of(context).popUntil(ModalRoute.withName(RouteNames.home)),
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
            if (!showContactForm && !isExistingProfileSelected) ...[
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
                    if (!showContactForm && !isExistingProfileSelected) ...[
                      // Contact type options
                      _buildContactTypeOption(
                        icon: Icons.person_outline,
                        title: 'Personal',
                        isSelected: selectedContactType == 'personal',
                        onTap: () {
                          setState(() {
                            selectedContactType = 'personal';
                            searchController.clear();
                            searchResults = [];
                            showSearchResults = false;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _buildContactTypeOption(
                        icon: Icons.business_outlined,
                        title: 'Business',
                        isSelected: selectedContactType == 'business',
                        onTap: () {
                          setState(() {
                            selectedContactType = 'business';
                            searchController.clear();
                            searchResults = [];
                            showSearchResults = false;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Search field (show when type is selected)
                      if (selectedContactType.isNotEmpty) ...[
                        Text(
                          selectedContactType == 'business' ? 'Company' : 'Name',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: selectedContactType == 'business' ? 'Company name' : 'Person name',
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

                        // Search results
                        if (showSearchResults && currentSearchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: BlocConsumer<ContactTypeCubit, ContactTypeState>(
                              listener: (context, state) {
                                if (state is ContactTypeSearchResult || state is ContactTypeError) {
                                  if (mounted) {
                                    setState(() {
                                      _isSearching = false;
                                    });
                                  }
                                }
                              },
                              builder: (context, state) {
                                if (_isSearching && state is! ContactTypeSearchResult) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                if (state is ContactTypeSearchResult) {
                                  searchResults = state.businesses;

                                  final hasExactMatch = searchResults.any((profile) {
                                    final name = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'
                                        .trim()
                                        .toLowerCase();
                                    final org = profile.organization?.toLowerCase() ?? '';
                                    return org == currentSearchQuery.toLowerCase() ||
                                        name == currentSearchQuery.toLowerCase();
                                  });

                                  final shouldShowNewOption = currentSearchQuery.isNotEmpty && !hasExactMatch;

                                  return Column(
                                    children: [
                                      // NEW option
                                      if (shouldShowNewOption) ...[
                                        GestureDetector(
                                          onTap: _selectNewProfile,
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

                                      // Existing results
                                      if (searchResults.isNotEmpty) ...[
                                        ...searchResults.map((profile) {
                                          final displayName =
                                              profile.organization ??
                                              '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
                                          final phone = context.read<ContactTypeCubit>().getPrimaryPhoneNumber(profile);

                                          return GestureDetector(
                                            onTap: () => _selectProfile(profile),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                border: searchResults.indexOf(profile) != searchResults.length - 1
                                                    ? Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))
                                                    : null,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName,
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
                                        }),
                                      ],

                                      if (searchResults.isEmpty && !shouldShowNewOption) ...[
                                        const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text('No results found', style: TextStyle(color: Colors.grey)),
                                        ),
                                      ],
                                    ],
                                  );
                                }

                                if (state is ContactTypeError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'Search failed: ${state.message}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ],
                    ],

                    // Contact form (for new profiles)
                    if (showContactForm) ...[
                      if (selectedContactType == 'business') ...[
                        const Text(
                          'Company name*',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: organizationController,
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
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Contact Person',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                      ],

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
                        onChanged: (_) => setState(() {}),
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
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 16),

                      // Email (Optional)
                      const Text('Email', style: TextStyle(fontSize: 14, color: Colors.black87)),
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

                      // Telephone (Optional)
                      const Text('Telephone (Mobile)', style: TextStyle(fontSize: 14, color: Colors.black87)),
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

                    // Extra space when type selected but no search
                    if (selectedContactType.isNotEmpty &&
                        !showContactForm &&
                        !isExistingProfileSelected &&
                        currentSearchQuery.isEmpty) ...[
                      const SizedBox(height: 80),
                    ],
                  ],
                ),
              ),
            ),

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
                          // This now only handles new profile creation
                          if (showContactForm) {
                            _saveNewProfileToJobBooking();
                            _navigateToNextScreen();
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
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.shade100,
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
    _scrollController.dispose();
    searchController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    super.dispose();
  }
}
