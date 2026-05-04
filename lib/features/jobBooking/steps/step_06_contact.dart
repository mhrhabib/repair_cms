// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

/// Step 6 – Contact Selection
///
/// Design  : StepContactWidget (underline fields, TitleWidget, auto phone-code)
/// Logic   : ChooseContactTypeScreen (search → select existing / create new)
///
/// Flow:
///   1. User picks Personal or Business
///   2. Search field appears → live search with 500 ms debounce
///   3a. Tap existing result  → form pre-fills for review/edit → Continue
///         • No changes  → save to cubit only → proceed
///         • Has changes → call updateBusiness API → proceed on success
///   3b. Tap NEW badge        → empty form → user fills → Continue
///         • Saves to cubit only (createBusiness is called in Step 7 with address)
class StepContactWidget extends StatefulWidget {
  const StepContactWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.onProfileSelected,
  });

  final void Function(bool canProceed) onCanProceedChanged;

  /// Fired when the user confirms their selection.
  /// [profile] is non-null for existing profiles, null for new ones.
  /// [isNew] is true when a brand-new profile will be created.
  final void Function(Customersorsuppliers? profile, bool isNew)
  onProfileSelected;

  @override
  State<StepContactWidget> createState() => StepContactWidgetState();
}

class StepContactWidgetState extends State<StepContactWidget> {
  // ── Contact type ──────────────────────────────────────────────────────────
  String selectedContactType = '';

  // ── Text controllers ──────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  // ── Focus nodes ───────────────────────────────────────────────────────────
  final FocusNode searchFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode organizationFocusNode = FocusNode();

  final ScrollController scrollController = ScrollController();

  // ── Phone code picker ─────────────────────────────────────────────────────
  String selectedPhoneCode = '+1';
  final countryPicker = const FlCountryCodePicker();

  // ── Search / UI state ─────────────────────────────────────────────────────
  List<Customersorsuppliers> searchResults = [];
  bool showSearchResults = false;
  bool showContactForm = false;
  String currentSearchQuery = '';
  bool isExistingProfileSelected = false;
  Customersorsuppliers? selectedProfile;
  Timer? _searchDebounceTimer;
  bool _isSearching = false;
  bool _isProgrammaticUpdate = false;

  // ── Remote-update state ───────────────────────────────────────────────────
  bool _isLoading = false;
  Completer<bool>? _updateCompleter;

  // ── Change-detection originals (existing profile) ─────────────────────────
  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalEmail = '';
  String _originalPhone = '';
  String _originalOrganization = '';

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _setupFocusListeners();
    _autoSelectPhoneCode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(_isFormValid);
    });
  }

  /// Pre-selects the dial-code from the logged-in SaaS user's location.
  void _autoSelectPhoneCode() {
    final userData = storage.read('user');
    if (userData == null) return;
    try {
      UserData user;
      if (userData is String) {
        user = UserData.fromJson(jsonDecode(userData));
      } else {
        user = UserData.fromJson(userData);
      }

      final country = user.location?.country;
      final prefix = user.location?.locationPrefix;
      bool isSetFromCountry = false;

      if (country != null && country.toString().trim().isNotEmpty) {
        final cleanCountry = country.toString().trim().toLowerCase();
        try {
          final matchedCode = countryPicker.countryCodes.firstWhere(
            (c) =>
                c.name.toLowerCase() == cleanCountry ||
                c.code.toLowerCase() == cleanCountry,
          );
          if (matchedCode.dialCode.isNotEmpty) {
            setState(() => selectedPhoneCode = matchedCode.dialCode);
            isSetFromCountry = true;
            debugPrint('Step6 – phone code from country: $selectedPhoneCode');
          }
        } catch (_) {}
      }

      if (!isSetFromCountry &&
          prefix != null &&
          prefix.toString().trim().isNotEmpty) {
        String cleanPrefix = prefix.toString().trim();
        if (!cleanPrefix.startsWith('+')) cleanPrefix = '+$cleanPrefix';
        setState(() => selectedPhoneCode = cleanPrefix);
        debugPrint('Step6 – phone code from prefix: $selectedPhoneCode');
      }
    } catch (e) {
      debugPrint('Step6 – error loading phone prefix: $e');
    }
  }

  void _setupFocusListeners() {
    firstNameFocusNode.addListener(
      () => _scrollToOffset(firstNameFocusNode, 80.h),
    );
    lastNameFocusNode.addListener(
      () => _scrollToOffset(lastNameFocusNode, 140.h),
    );
    emailFocusNode.addListener(() => _scrollToOffset(emailFocusNode, 200.h));
    phoneFocusNode.addListener(() => _scrollToOffset(phoneFocusNode, 260.h));
    organizationFocusNode.addListener(
      () => _scrollToOffset(organizationFocusNode, 40.h),
    );
  }

  void _scrollToOffset(FocusNode node, double offset) {
    if (node.hasFocus && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && scrollController.hasClients) {
          scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Search
  // ─────────────────────────────────────────────────────────────────────────

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
          if (mounted) setState(() => _isSearching = false);
        });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Selection: existing profile
  // ─────────────────────────────────────────────────────────────────────────

  void _selectProfile(Customersorsuppliers profile) {
    final contactTypeCubit = context.read<ContactTypeCubit>();
    final primaryEmail = contactTypeCubit.getPrimaryEmail(profile);

    if (mounted) {
      setState(() {
        final displayName = (profile.organization?.isNotEmpty ?? false)
            ? profile.organization!
            : '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();

        _isProgrammaticUpdate = true;
        searchController.text = displayName;
        _isProgrammaticUpdate = false;

        showSearchResults = false;

        // Pre-fill form so the user can review / edit
        firstNameController.text = profile.firstName ?? '';
        lastNameController.text = profile.lastName ?? '';
        organizationController.text = profile.organization ?? '';
        emailController.text = primaryEmail ?? '';
        final phoneDetails = contactTypeCubit.getPrimaryPhoneDetails(profile);
        if (phoneDetails != null) {
          final prefix = phoneDetails['prefix'] ?? '';
          final number = phoneDetails['number'] ?? '';
          phoneController.text = number.replaceAll(RegExp(r'[^\d]'), '');
          if (prefix.isNotEmpty) selectedPhoneCode = prefix;
        }

        // Snapshot originals for change-detection
        _originalFirstName = firstNameController.text;
        _originalLastName = lastNameController.text;
        _originalEmail = emailController.text;
        _originalPhone = phoneController.text;
        _originalOrganization = organizationController.text;

        showContactForm = true;
        isExistingProfileSelected = true;
        selectedProfile = profile;
        _isSearching = false;
      });
    }

    // Persist to cubit immediately so Step 7 can read it
    _saveExistingProfileToJobBooking(profile);

    // Continue button enabled; user reviews form then taps Continue
    widget.onCanProceedChanged(true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Selection: new profile
  // ─────────────────────────────────────────────────────────────────────────

  void _selectNewProfile() {
    // Clear any stale address so Step 7 starts fresh
    final jobBookingCubit = context.read<JobBookingCubit>();
    final emptyAddress = CustomerAddress(
      street: '',
      no: '',
      city: '',
      zip: '',
      state: '',
      country: '',
    );
    jobBookingCubit.updateShippingAddress(emptyAddress);
    jobBookingCubit.updateBillingAddress(emptyAddress);

    if (mounted) {
      setState(() {
        if (selectedContactType == 'business') {
          organizationController.text = currentSearchQuery;
          firstNameController.clear();
          lastNameController.clear();
        } else {
          final nameParts = currentSearchQuery.split(' ');
          firstNameController.text = nameParts.isNotEmpty
              ? nameParts.first
              : '';
          lastNameController.text = nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : '';
          organizationController.clear();
        }
        emailController.clear();
        phoneController.clear();

        showSearchResults = false;
        showContactForm = true;
        isExistingProfileSelected = false;
        selectedProfile = null;
        _isSearching = false;
      });

      widget.onCanProceedChanged(_isFormValid);

      // Scroll to form and focus first relevant field
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          scrollController.animateTo(
            80.h,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          if (selectedContactType == 'business') {
            organizationFocusNode.requestFocus();
          } else {
            firstNameFocusNode.requestFocus();
          }
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JobBooking cubit helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Persist an existing profile's data into the cubit (called on first tap).
  void _saveExistingProfileToJobBooking(Customersorsuppliers profile) {
    final jobBookingCubit = context.read<JobBookingCubit>();
    final contactTypeCubit = context.read<ContactTypeCubit>();

    final primaryPhone = contactTypeCubit.getPrimaryPhoneNumber(profile);
    final primaryEmail = contactTypeCubit.getPrimaryEmail(profile);

    jobBookingCubit.updateContactType(
      type: selectedContactType == 'business' ? 'Business' : 'Personal',
      type2: selectedContactType,
      organization: profile.organization ?? '',
      customerNo: profile.customerNumber ?? '',
      position: profile.position ?? '',
    );

    final phoneDetails = contactTypeCubit.getPrimaryPhoneDetails(profile);
    final phoneNumber =
        phoneDetails?['number']?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    final phonePrefix =
        phoneDetails?['prefix'] ??
        primaryPhone?.replaceAll(RegExp(r'[^\d+]'), '') ??
        '';

    jobBookingCubit.updateCustomerInfo(
      salutation: profile.supplierName ?? '',
      firstName: profile.firstName ?? '',
      lastName: profile.lastName ?? '',
      telephone: phoneNumber,
      telephonePrefix: phonePrefix.isNotEmpty
          ? phonePrefix
          : _extractPhonePrefix(primaryPhone),
      email: primaryEmail ?? '',
      customerId: profile.sId ?? '',
    );

    // Pre-populate address if the profile already has one
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

  /// Sync any edits the user made in the existing-profile form into the cubit.
  void _updateExistingProfileInJobBooking() {
    final jobBookingCubit = context.read<JobBookingCubit>();

    jobBookingCubit.updateCustomerInfo(
      salutation: '',
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      telephone: phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
      telephonePrefix: selectedPhoneCode,
      email: emailController.text,
      customerId: selectedProfile?.sId ?? '',
    );

    if (selectedContactType == 'business') {
      jobBookingCubit.updateContactType(
        type: 'Business',
        type2: selectedContactType,
        organization: organizationController.text,
        customerNo: selectedProfile?.customerNumber ?? '',
        position: selectedProfile?.position ?? '',
      );
    }
  }

  /// Save a new-profile's form data into the cubit.
  /// NOTE: the actual createBusiness API call happens in Step 7 once the
  /// address is also known.
  void _saveNewProfileToJobBooking() {
    final jobBookingCubit = context.read<JobBookingCubit>();

    jobBookingCubit.updateContactType(
      type: selectedContactType == 'business' ? 'Business' : 'Personal',
      type2: selectedContactType,
      organization: selectedContactType == 'business'
          ? organizationController.text
          : '',
      customerNo: '',
      position: selectedContactType == 'business' ? 'Customer' : '',
    );

    jobBookingCubit.updateCustomerInfo(
      salutation: '',
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      telephone: phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
      telephonePrefix: selectedPhoneCode,
      email: emailController.text,
      customerId: '',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Remote profile update (existing profile with user edits)
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _updateProfileRemotely() async {
    if (selectedProfile?.sId == null) return false;

    setState(() => _isLoading = true);
    _updateCompleter = Completer<bool>();

    final contactTypeCubit = context.read<ContactTypeCubit>();

    final payload = contactTypeCubit.createBusinessPayload(
      type: selectedContactType == 'business' ? 'Business' : 'Personal',
      type2: selectedContactType,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      organization: organizationController.text,
      position: selectedProfile?.position ?? '',
      userId: storage.read('userId') ?? '',
      location: storage.read('locationId') ?? '6568646e9c9d411a9ce57145',
      // We deliberately omit shippingAddresses and billingAddresses here
      // because Step 7 handles address updates via separate PATCH APIs.
      emails: [
        {'email': emailController.text, 'type': 'Private', 'isPrimary': true},
      ],
      telephones: [
        {
          'number': phoneController.text,
          'phone_prefix': selectedPhoneCode,
          'type': 'Private',
          'isPrimary': true,
        },
      ],
    );

    contactTypeCubit.updateBusiness(
      profileId: selectedProfile!.sId!,
      payload: payload,
    );

    return _updateCompleter!.future;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validation – called by the wizard via GlobalKey
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> validate() async {
    // ── Existing profile ──────────────────────────────────────────────────
    if (isExistingProfileSelected && showContactForm) {
      _updateExistingProfileInJobBooking();

      if (_hasProfileChanges) {
        debugPrint('Step6 validate: changes detected → remote update');
        final success = await _updateProfileRemotely();
        if (success) widget.onProfileSelected(selectedProfile, false);
        return success;
      } else {
        debugPrint('Step6 validate: no changes → proceed');
        widget.onProfileSelected(selectedProfile, false);
        return true;
      }
    }

    // ── New profile ───────────────────────────────────────────────────────
    if (showContactForm && !isExistingProfileSelected) {
      if (_isFormValid) {
        _saveNewProfileToJobBooking();
        widget.onProfileSelected(null, true);
        return true;
      }
      return false;
    }

    return isExistingProfileSelected;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  bool _hasCompleteAddress(ShippingAddresses? address) {
    if (address == null) return false;
    return (address.street?.isNotEmpty ?? false) &&
        (address.city?.isNotEmpty ?? false) &&
        (address.zip?.isNotEmpty ?? false);
  }

  String? _extractPhonePrefix(String? phone) {
    if (phone == null) return '+1';
    final match = RegExp(r'^(\+\d+)').firstMatch(phone);
    return match?.group(1) ?? '+1';
  }

  bool get _isFormValid {
    if (isExistingProfileSelected) return true; // always allow proceed

    if (showContactForm) {
      final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      );
      final isEmailValid = emailRegex.hasMatch(emailController.text.trim());

      final basicValid =
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          isEmailValid;

      if (selectedContactType == 'business') {
        return basicValid && organizationController.text.isNotEmpty;
      }
      return basicValid;
    }
    return false;
  }

  bool get _hasProfileChanges =>
      firstNameController.text != _originalFirstName ||
      lastNameController.text != _originalLastName ||
      emailController.text != _originalEmail ||
      phoneController.text != _originalPhone ||
      organizationController.text != _originalOrganization;

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactTypeCubit, ContactTypeState>(
      listener: (context, state) {
        // Only process remote-update responses
        if (!_isLoading || _updateCompleter == null) return;

        if (state is ContactTypeSuccess) {
          setState(() => _isLoading = false);
          debugPrint('Step6: profile update successful');
          if (!_updateCompleter!.isCompleted) {
            widget.onProfileSelected(selectedProfile, false);
            _updateCompleter!.complete(true);
          }
        } else if (state is ContactTypeError) {
          setState(() => _isLoading = false);
          debugPrint('Step6: profile update failed – ${state.message}');
          showCustomToast(
            'Failed to update profile: ${state.message}',
            isError: true,
          );
          if (!_updateCompleter!.isCompleted) {
            _updateCompleter!.complete(false);
          }
        }
      },
      child: Stack(
        children: [
          // ── Main scrollable content ───────────────────────────────────
          CustomScrollView(
            controller: scrollController,
            slivers: [
              // Title
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TitleWidget(
                        stepNumber: 6,
                        title: 'Choose the contact type',
                        subTitle: 'Personal or Business account',
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),

              // Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Phase A: type selection + search ───────────────
                      if (!showContactForm) ...[
                        _buildContactTypeOption(
                          icon: Icons.person_outline,
                          title: 'Personal',
                          isSelected: selectedContactType == 'personal',
                          onTap: () => _onContactTypeTap('personal'),
                        ),
                        SizedBox(height: 16.h),
                        _buildContactTypeOption(
                          icon: Icons.business_outlined,
                          title: 'Business',
                          isSelected: selectedContactType == 'business',
                          onTap: () => _onContactTypeTap('business'),
                        ),
                        SizedBox(height: 32.h),

                        if (selectedContactType.isNotEmpty) ...[
                          Text(
                            selectedContactType == 'business'
                                ? 'Company'
                                : 'Name',
                            style: AppTypography.fontSize16,
                          ),
                          SizedBox(height: 8.h),
                          // Search field
                          TextField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            cursorColor: AppColors.warningColor,
                            style: GoogleFonts.roboto(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fontMainColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search here...',
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 24.sp,
                                color: const Color(0xFFB2B5BE),
                                fontWeight: FontWeight.w400,
                              ),

                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8.h,
                              ),
                            ),
                          ),

                          // Search dropdown
                          if (showSearchResults &&
                              currentSearchQuery.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _buildSearchDropdown(),
                          ],
                        ],
                      ],

                      // ── Phase B: contact form ──────────────────────────
                      if (showContactForm) ...[
                        // Type badge + "Change" button
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    selectedContactType == 'business'
                                        ? Icons.business_outlined
                                        : Icons.person_outline,
                                    size: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    selectedContactType == 'business'
                                        ? 'Business'
                                        : 'Personal',
                                    style: AppTypography.fontSize14.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _resetToTypeSelection,
                              child: Text(
                                'Change',
                                style: AppTypography.fontSize14.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Existing-profile notice
                        if (isExistingProfileSelected) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16.sp,
                                  color: Colors.green.shade700,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Existing profile — review and edit if needed',
                                    style: AppTypography.fontSize14.copyWith(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        _buildContactForm(),
                      ],
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 400.h)),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(),
              ),
            ],
          ),

          // ── Loading overlay ───────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.white.withAlpha(180),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Contact-type card tap
  // ─────────────────────────────────────────────────────────────────────────

  void _onContactTypeTap(String type) {
    setState(() {
      selectedContactType = type;
      searchController.clear();
      searchResults = [];
      showSearchResults = false;
    });
    widget.onCanProceedChanged(false);
    searchFocusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        scrollController.animateTo(
          200.h,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Return to the type-selection / search phase.
  void _resetToTypeSelection() {
    setState(() {
      showContactForm = false;
      showSearchResults = false;
      isExistingProfileSelected = false;
      selectedProfile = null;
      searchController.clear();
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      phoneController.clear();
      organizationController.clear();
      currentSearchQuery = '';
    });
    widget.onCanProceedChanged(false);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Search dropdown
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSearchDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: BlocConsumer<ContactTypeCubit, ContactTypeState>(
        listener: (context, state) {
          if ((state is ContactTypeSearchResult || state is ContactTypeError) &&
              mounted) {
            setState(() => _isSearching = false);
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
            final results = state.businesses;

            final hasExactMatch = results.any(
              (p) =>
                  (p.organization?.toLowerCase() ==
                      currentSearchQuery.toLowerCase()) ||
                  ('${p.firstName ?? ''} ${p.lastName ?? ''}'
                          .trim()
                          .toLowerCase() ==
                      currentSearchQuery.toLowerCase()),
            );
            final shouldShowNew =
                currentSearchQuery.isNotEmpty && !hasExactMatch;

            return Column(
              children: [
                if (shouldShowNew) _buildNewOptionTile(),
                ...results.map((p) => _buildProfileTile(p)),
                if (results.isEmpty && !shouldShowNew)
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
    );
  }

  Widget _buildNewOptionTile() {
    return GestureDetector(
      onTap: _selectNewProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
    final displayName = (profile.organization?.isNotEmpty ?? false)
        ? profile.organization!
        : '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();

    return GestureDetector(
      onTap: () => _selectProfile(profile),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdownSearch.highlightedText(
              text: displayName,
              query: currentSearchQuery,
              style: TextStyle(fontSize: 20.sp, color: AppColors.fontMainColor),
            ),
            Text(
              profile.customerNumber ?? 'No customer number',
              style: AppTypography.fontSize14.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Contact form
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business: company name block first
        if (selectedContactType == 'business') ...[
          Text('Company name*', style: AppTypography.fontSize16),
          SizedBox(height: 8.h),
          _buildTextField(
            focusNode: organizationFocusNode,
            controller: organizationController,
            hint: 'Company name',
          ),
          SizedBox(height: 24.h),
          Text('Contact Person', style: AppTypography.fontSize16),
          SizedBox(height: 16.h),
        ],

        Text('First Name*', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(
          focusNode: firstNameFocusNode,
          controller: firstNameController,
          hint: 'John',
        ),
        SizedBox(height: 16.h),

        Text('Last Name*', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(
          focusNode: lastNameFocusNode,
          controller: lastNameController,
          hint: 'Markinson',
        ),
        SizedBox(height: 16.h),

        Text('Email*', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        _buildTextField(
          focusNode: emailFocusNode,
          controller: emailController,
          hint: 'name@company.com',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),

        Text('Telephone (Mobile)*', style: AppTypography.fontSize14),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Dial-code picker
            GestureDetector(
              onTap: _showPhoneCodePicker,
              child: Container(
                width: 90.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedPhoneCode,
                        style: GoogleFonts.roboto(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.fontMainColor,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildTextField(
                focusNode: phoneFocusNode,
                controller: phoneController,
                hint: '123456789',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Future<void> _showPhoneCodePicker() async {
    final code = await countryPicker.showPicker(context: context);
    if (code != null && mounted) {
      setState(() => selectedPhoneCode = code.dialCode);
      widget.onCanProceedChanged(_isFormValid);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared underline text field
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      cursorColor: AppColors.blackColor,
      textInputAction: TextInputAction.next,
      style: GoogleFonts.roboto(
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.fontMainColor,
      ),
      onChanged: (_) {
        setState(() {});
        widget.onCanProceedChanged(_isFormValid);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.roboto(
          fontSize: 18.sp,
          color: const Color(0xFFB2B5BE),
          fontWeight: FontWeight.w400,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Contact-type card
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    organizationFocusNode.dispose();
    super.dispose();
  }
}
