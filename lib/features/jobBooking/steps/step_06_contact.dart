import 'dart:async';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 6 – Contact Selection (Existing Search or New Entry)
class StepContactWidget extends StatefulWidget {
  const StepContactWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.onProfileSelected,
  });

  final void Function(bool canProceed) onCanProceedChanged;
  final void Function(Customersorsuppliers? profile, bool isNew)
  onProfileSelected;

  @override
  State<StepContactWidget> createState() => StepContactWidgetState();
}

class StepContactWidgetState extends State<StepContactWidget> {
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
  bool _isProgrammaticUpdate = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    // Initial validation check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(_isFormValid);
    });
  }

  void _onSearchChanged() {
    if (_isProgrammaticUpdate) return;
    final query = searchController.text.trim();
    currentSearchQuery = query;

    _searchDebounceTimer?.cancel();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = [];
          showSearchResults = false;
          showNewOption = false;
          isExistingProfileSelected = false;
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        showSearchResults = true;
        _isSearching = true;
      });
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (!mounted) return;
    context
        .read<ContactTypeCubit>()
        .searchProfilesApi(
          userId: storage.read('userId') ?? '',
          query: query,
          type2: selectedContactType,
          limit: 5,
        )
        .then((_) {
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
        });
  }

  void _selectProfile(Customersorsuppliers profile) {
    if (mounted) {
      setState(() {
        final displayName =
            profile.organization ??
            '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
        _isProgrammaticUpdate = true;
        searchController.text = displayName;
        _isProgrammaticUpdate = false;
        showSearchResults = false;
        showNewOption = false;
        showContactForm = false;
        isExistingProfileSelected = true;
        selectedProfile = profile;
        _isSearching = false;
      });
    }

    _saveProfileToJobBooking(profile);
    // Immediate navigation to next screen handled by parent wizard via callback
    widget.onProfileSelected(profile, false);
  }

  void _selectNewProfile() {
    if (mounted) {
      setState(() {
        if (selectedContactType == 'business') {
          organizationController.text = currentSearchQuery;
        } else {
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
      widget.onCanProceedChanged(_isFormValid);
    }
  }

  void _saveProfileToJobBooking(Customersorsuppliers profile) {
    final jobBookingCubit = context.read<JobBookingCubit>();
    final contactTypeCubit = context.read<ContactTypeCubit>();

    final primaryPhone = contactTypeCubit.getPrimaryPhoneNumber(profile);
    final primaryEmail = contactTypeCubit.getPrimaryEmail(profile);

    jobBookingCubit.updateContactType(
      type: selectedContactType == 'business' ? "Business" : "Personal",
      type2: selectedContactType,
      organization: profile.organization ?? '',
      customerNo: profile.customerNumber ?? '',
      position: profile.position ?? '',
    );

    jobBookingCubit.updateCustomerInfo(
      salutation: profile.supplierName ?? '',
      firstName: profile.firstName ?? '',
      lastName: profile.lastName ?? '',
      telephone: primaryPhone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '',
      telephonePrefix: _extractPhonePrefix(primaryPhone),
      email: primaryEmail ?? '',
      customerId: profile.sId ?? '',
    );

    final shippingAddress = contactTypeCubit.getPrimaryShippingAddress(profile);
    if (_hasCompleteAddress(shippingAddress)) {
      final address = CustomerAddress(
        id: shippingAddress?.sId ?? '',
        street: shippingAddress?.street ?? '',
        no: shippingAddress?.iV?.toString() ?? '',
        city: shippingAddress?.city ?? '',
        zip: shippingAddress?.zip ?? '',
        country: shippingAddress?.country ?? '',
        state: shippingAddress?.city ?? '',
      );
      jobBookingCubit.updateShippingAddress(address);
      jobBookingCubit.updateBillingAddress(address);
    }
  }

  void _saveNewProfileToJobBooking() {
    final jobBookingCubit = context.read<JobBookingCubit>();
    jobBookingCubit.updateContactType(
      type: selectedContactType == 'business' ? "Business" : "Personal",
      type2: selectedContactType,
      organization: selectedContactType == 'business'
          ? organizationController.text
          : '',
      customerNo: '',
      position: selectedContactType == 'business' ? "Customer" : '',
    );

    jobBookingCubit.updateCustomerInfo(
      salutation: '',
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      telephone: phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
      telephonePrefix: "+1",
      email: emailController.text,
      customerId: '',
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

  bool get _isFormValid {
    if (showContactForm) {
      final basicFieldsValid =
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty;
      if (selectedContactType == 'business') {
        return basicFieldsValid && organizationController.text.isNotEmpty;
      }
      return basicFieldsValid;
    }
    return false;
  }

  /// Exposed for wizard validation before proceeding with NEW record
  bool validate() {
    if (showContactForm) {
      if (_isFormValid) {
        _saveNewProfileToJobBooking();
        widget.onProfileSelected(null, true);
        return true;
      }
      return false;
    }
    return isExistingProfileSelected;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (!showContactForm && !isExistingProfileSelected) ...[
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 24.h),
                TitleWidget(
                  stepNumber: 6,
                  title: 'Choose the contact type',
                  subTitle: 'Personal or Business account',
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!showContactForm && !isExistingProfileSelected) ...[
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
                      widget.onCanProceedChanged(false);
                    },
                  ),
                  SizedBox(height: 16.h),
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
                      widget.onCanProceedChanged(false);
                    },
                  ),
                  SizedBox(height: 32.h),
                  if (selectedContactType.isNotEmpty) ...[
                    Text(
                      selectedContactType == 'business' ? 'Company' : 'Name',
                      style: AppTypography.fontSize16,
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: selectedContactType == 'business'
                            ? 'Company name'
                            : 'Person name',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    if (showSearchResults && currentSearchQuery.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _buildSearchResults(),
                    ],
                  ],
                ],
                if (showContactForm) _buildContactForm(),
              ],
            ),
          ),
        ),
        const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<ContactTypeCubit, ContactTypeState>(
        builder: (context, state) {
          if (_isSearching && state is! ContactTypeSearchResult) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is ContactTypeSearchResult) {
            final results = state.businesses;
            final hasExactMatch = results.any(
              (p) =>
                  (p.organization?.toLowerCase() ==
                      currentSearchQuery.toLowerCase()) ||
                  ('${p.firstName} ${p.lastName}'.trim().toLowerCase() ==
                      currentSearchQuery.toLowerCase()),
            );
            final shouldShowNewOption =
                currentSearchQuery.isNotEmpty && !hasExactMatch;

            return Column(
              children: [
                if (shouldShowNewOption) _buildNewOptionTile(),
                ...results.map((profile) => _buildProfileTile(profile)),
                if (results.isEmpty && !shouldShowNewOption)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No results found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNewOptionTile() {
    return GestureDetector(
      onTap: _selectNewProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(currentSearchQuery, style: AppTypography.fontSize16),
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
    );
  }

  Widget _buildProfileTile(Customersorsuppliers profile) {
    final displayName =
        profile.organization ??
        '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
    return GestureDetector(
      onTap: () => _selectProfile(profile),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: AppTypography.fontSize16),
            Text(
              profile.customerNumber ?? 'No customer number',
              style: AppTypography.fontSize14.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedContactType == 'business') ...[
          Text('Company name*', style: AppTypography.fontSize16),
          SizedBox(height: 8.h),
          _buildTextField(organizationController, 'Company name'),
          SizedBox(height: 24.h),
          Text('Contact Person', style: AppTypography.fontSize16),
          SizedBox(height: 16.h),
        ],
        Text('First Name*', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(firstNameController, 'John'),
        SizedBox(height: 16.h),
        Text('Last Name*', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(lastNameController, 'Markinson'),
        SizedBox(height: 16.h),
        Text('Email', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(
          emailController,
          'name@company.com',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        Text('Telephone (Mobile)', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(
          phoneController,
          '+1-123456789',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) {
        setState(() {});
        widget.onCanProceedChanged(_isFormValid);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
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
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppTypography.fontSize16.copyWith(
                  color: isSelected ? AppColors.primary : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    super.dispose();
  }
}
