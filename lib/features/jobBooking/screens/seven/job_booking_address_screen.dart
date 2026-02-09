import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/screens/eight/job_booking_job_type_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingAddressScreen extends StatefulWidget {
  final bool isNewProfile; // Indicates if we're creating a new profile
  final Customersorsuppliers? selectedProfile; // The selected existing profile

  const JobBookingAddressScreen({super.key, this.isNewProfile = false, this.selectedProfile});

  @override
  State<JobBookingAddressScreen> createState() => _JobBookingAddressScreenState();
}

class _JobBookingAddressScreenState extends State<JobBookingAddressScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  // Controllers for first page
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Controllers for second page
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false; // Track if user made changes to existing profile
  bool _hasHandledContactSuccess = false; // Prevent repeated navigation on ContactTypeSuccess

  // Store original values to detect changes
  String _originalStreet = '';
  String _originalHouseNumber = '';
  String _originalCity = '';
  String _originalPostalCode = '';
  String _originalProvince = '';
  String _originalCountry = '';

  @override
  void initState() {
    super.initState();

    // Set default country
    _countryController.text = "";

    if (!widget.isNewProfile && widget.selectedProfile != null) {
      _loadExistingProfileAddressData();
    } else if (!widget.isNewProfile) {
      _loadExistingAddressDataFromJobBooking();
    }

    // Add listeners to detect changes
    _addChangeListeners();
  }

  void _addChangeListeners() {
    void checkForChanges() {
      final hasChanges =
          _addressController.text != _originalStreet ||
          _houseNumberController.text != _originalHouseNumber ||
          _cityController.text != _originalCity ||
          _postalCodeController.text != _originalPostalCode ||
          _provinceController.text != _originalProvince ||
          _countryController.text != _originalCountry;

      if (mounted) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }

    _addressController.addListener(checkForChanges);
    _houseNumberController.addListener(checkForChanges);
    _cityController.addListener(checkForChanges);
    _postalCodeController.addListener(checkForChanges);
    _provinceController.addListener(checkForChanges);
    _countryController.addListener(checkForChanges);
  }

  void _loadExistingProfileAddressData() {
    if (widget.selectedProfile != null) {
      final contactTypeCubit = context.read<ContactTypeCubit>();
      final shippingAddress = contactTypeCubit.getPrimaryShippingAddress(widget.selectedProfile!);

      if (shippingAddress != null) {
        _addressController.text = shippingAddress.street ?? '';
        _houseNumberController.text = shippingAddress.iV?.toString() ?? '';
        _cityController.text = shippingAddress.city ?? '';
        _postalCodeController.text = shippingAddress.zip ?? '';
        _provinceController.text = shippingAddress.city ?? '';
        _countryController.text = shippingAddress.country ?? "";

        // Store original values
        _originalStreet = _addressController.text;
        _originalHouseNumber = _houseNumberController.text;
        _originalCity = _cityController.text;
        _originalPostalCode = _postalCodeController.text;
        _originalProvince = _provinceController.text;
        _originalCountry = _countryController.text;
      }
    }
  }

  void _loadExistingAddressDataFromJobBooking() {
    final state = context.read<JobBookingCubit>().state;
    if (state is JobBookingData) {
      // Load shipping address data if available (field-level null checks)
      final shippingAddress = state.contact.shippingAddress;
      if ((shippingAddress.street ?? '').isNotEmpty) {
        _addressController.text = shippingAddress.street!;
      }
      if ((shippingAddress.no ?? '').isNotEmpty) {
        _houseNumberController.text = shippingAddress.no!;
      }
      if ((shippingAddress.city ?? '').isNotEmpty) {
        _cityController.text = shippingAddress.city!;
      }
      if ((shippingAddress.zip ?? '').isNotEmpty) {
        _postalCodeController.text = shippingAddress.zip!;
      }
      if ((shippingAddress.state ?? '').isNotEmpty) {
        _provinceController.text = shippingAddress.state!;
      }
      if ((shippingAddress.country ?? '').isNotEmpty) {
        _countryController.text = shippingAddress.country!;
      }

      // Store original values
      _originalStreet = _addressController.text;
      _originalHouseNumber = _houseNumberController.text;
      _originalCity = _cityController.text;
      _originalPostalCode = _postalCodeController.text;
      _originalProvince = _provinceController.text;
      _originalCountry = _countryController.text;
    }
  }

  bool get _isFirstPageValid {
    return _addressController.text.isNotEmpty &&
        _houseNumberController.text.isNotEmpty &&
        _cityController.text.isNotEmpty;
  }

  bool get _isSecondPageValid {
    return _postalCodeController.text.isNotEmpty;
    // Province and Country are optional
  }

  void _saveAddressToCubit() {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobBookingCubit = context.read<JobBookingCubit>();

      // Create address object
      final address = CustomerAddress(
        id: "", // Will be generated by backend
        street: _addressController.text,
        no: _houseNumberController.text,
        city: _cityController.text,
        zip: _postalCodeController.text,
        state: _provinceController.text.isNotEmpty ? _provinceController.text : 'N/A',
        country: _countryController.text.isNotEmpty ? _countryController.text : "",
      );

      // Update both shipping and billing addresses in cubit
      jobBookingCubit.updateShippingAddress(address);
      jobBookingCubit.updateBillingAddress(address);

      debugPrint('✅ Address saved to JobBookingCubit:');
      debugPrint('   📍 Street: ${_addressController.text} ${_houseNumberController.text}');
      debugPrint('   🏙️ City: ${_cityController.text}');
      debugPrint('   📮 Postal Code: ${_postalCodeController.text}');
      debugPrint('   🗺️ Province: ${_provinceController.text}');
      debugPrint('   🌍 Country: ${_countryController.text}');

      // Handle different scenarios
      if (widget.isNewProfile) {
        // New profile - create with address
        _createProfileWithAddress();
      } else if (_hasChanges && widget.selectedProfile != null) {
        // Existing profile with changes - update the profile
        _updateProfileWithAddress();
      } else {
        // Existing profile without changes - just navigate
        _navigateToNextScreen();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving address: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      showCustomToast('Error saving address: ${e.toString()}', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createProfileWithAddress() {
    final jobBookingCubit = context.read<JobBookingCubit>();
    final contactTypeCubit = context.read<ContactTypeCubit>();

    // Get current job booking state
    final jobBookingState = jobBookingCubit.state;
    if (jobBookingState is! JobBookingData) {
      debugPrint('❌ JobBookingData not found');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final contact = jobBookingState.contact;

    // Prepare address data
    final addressData = {
      "street": _addressController.text,
      "no": _houseNumberController.text,
      "city": _cityController.text,
      "zip": _postalCodeController.text,
      "state": _provinceController.text,
      "country": _countryController.text.isNotEmpty ? _countryController.text : "",
      "primary": true,
    };

    final payload = contactTypeCubit.createBusinessPayload(
      type: contact.type,
      type2: contact.type2,
      firstName: contact.firstName,
      lastName: contact.lastName,
      organization: contact.organization,
      position: contact.position,
      userId: _getUserId(),
      location: _getLocationId(),
      shippingAddresses: [addressData],
      billingAddresses: [addressData],
      // Add email and phone if available
      emails: contact.email.isNotEmpty
          ? [
              {"email": contact.email, "type": "Private", "isPrimary": true},
            ]
          : null,
      telephones: contact.telephone.isNotEmpty
          ? [
              {
                "number": contact.telephone,
                "phone_prefix": contact.telephonePrefix,
                "type": "Private",
                "isPrimary": true,
              },
            ]
          : null,
    );

    debugPrint('🚀 Creating new profile with address...');
    contactTypeCubit.createBusiness(payload: payload);
  }

  void _updateProfileWithAddress() {
    final jobBookingCubit = context.read<JobBookingCubit>();
    final contactTypeCubit = context.read<ContactTypeCubit>();

    // Get current job booking state
    final jobBookingState = jobBookingCubit.state;
    if (jobBookingState is! JobBookingData) {
      debugPrint('❌ JobBookingData not found');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final contact = jobBookingState.contact;

    // Prepare address data
    final addressData = {
      "street": _addressController.text,
      "no": _houseNumberController.text,
      "city": _cityController.text,
      "zip": _postalCodeController.text,
      "state": _provinceController.text,
      "country": _countryController.text.isNotEmpty ? _countryController.text : "",
      "primary": true,
    };

    final payload = contactTypeCubit.createBusinessPayload(
      type: contact.type,
      type2: contact.type2,
      firstName: contact.firstName,
      lastName: contact.lastName,
      organization: contact.organization,
      position: contact.position,
      userId: _getUserId(),
      location: _getLocationId(),
      shippingAddresses: [addressData],
      billingAddresses: [addressData],
      // Add email and phone if available
      emails: contact.email.isNotEmpty
          ? [
              {"email": contact.email, "type": "Private", "isPrimary": true},
            ]
          : null,
      telephones: contact.telephone.isNotEmpty
          ? [
              {
                "number": contact.telephone,
                "phone_prefix": contact.telephonePrefix,
                "type": "Private",
                "isPrimary": true,
              },
            ]
          : null,
    );

    debugPrint('🚀 Updating existing profile with new address...');
    debugPrint('   📝 Profile ID: ${widget.selectedProfile!.sId}');
    debugPrint('   📦 Has changes: $_hasChanges');

    contactTypeCubit.updateBusiness(profileId: widget.selectedProfile!.sId!, payload: payload);
  }

  String _getUserId() {
    return storage.read('userId') ?? '';
  }

  String _getLocationId() {
    return storage.read('locationId') ?? '6568646e9c9d411a9ce57145';
  }

  void _handleNextButton() {
    if (currentPage == 0) {
      if (_isFirstPageValid) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        showCustomToast('Please fill all required fields', isError: true);
      }
    } else {
      if (_isSecondPageValid) {
        _saveAddressToCubit();
      } else {
        showCustomToast('Please fill postal code', isError: true);
      }
    }
  }

  void _navigateToNextScreen() {
    setState(() {
      _isLoading = false;
    });
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const JobBookingJobTypeScreen(),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactTypeCubit, ContactTypeState>(
      listener: (context, state) {
        if (state is ContactTypeSuccess && !_hasHandledContactSuccess) {
          _hasHandledContactSuccess = true;
          debugPrint('✅ ${widget.isNewProfile ? 'Profile created' : 'Profile updated'} successfully with address');

          // Update the customer ID in JobBookingCubit with the created/updated profile
          if (state.createdBusiness?.sId != null) {
            final jobBookingCubit = context.read<JobBookingCubit>();
            final currentState = jobBookingCubit.state;

            if (currentState is JobBookingData) {
              jobBookingCubit.updateCustomerInfo(
                salutation: currentState.contact.salutation,
                firstName: currentState.contact.firstName,
                lastName: currentState.contact.lastName,
                telephone: currentState.contact.telephone,
                telephonePrefix: currentState.contact.telephonePrefix,
                email: currentState.contact.email,
                customerId: state.createdBusiness!.sId!,
              );
            }
          }

          _navigateToNextScreen();
        } else if (state is ContactTypeError) {
          debugPrint('❌ Error ${widget.isNewProfile ? 'creating' : 'updating'} profile: ${state.message}');
          showCustomToast(
            'Error ${widget.isNewProfile ? 'creating' : 'updating'} profile: ${state.message}',
            isError: true,
          );
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
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
                      width: MediaQuery.of(context).size.width * .071 * 7,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(0),
                        ),
                        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                      ),
                    ),
                  ),
                ),
              ),

              // Header with back button
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
                      const Spacer(),
                      // Show profile info
                      // if (widget.isNewProfile)
                      //   Text(
                      //     'New ${widget.selectedProfile?.type2 ?? 'profile'}',
                      //     style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w500),
                      //   ),
                      if (!widget.isNewProfile && widget.selectedProfile != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Existing profile',
                              style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.w500),
                            ),
                            if (_hasChanges)
                              Text('Changes detected', style: TextStyle(color: Colors.orange[600], fontSize: 12)),
                          ],
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
                    child: Center(
                      child: Text(
                        '${7}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 24)),

              // Title
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    currentPage == 0 ? 'Address details' : 'Additional address details',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 32)),

              // Page view for address forms
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    children: [_buildFirstAddressForm(), _buildSecondAddressForm()],
                  ),
                ),
              ),

              // Page indicators
              SliverToBoxAdapter(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildPageIndicator(0), const SizedBox(width: 8), _buildPageIndicator(1)],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 100)),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8, left: 24, right: 24),
          child: SizedBox(
            height: 48,
            child: BottomButtonsGroup(
              onPressed: _isLoading ? null : _handleNextButton,
              okButtonText: currentPage == 1
                  ? (_hasChanges && !widget.isNewProfile ? 'Update & Continue' : 'Save & Continue')
                  : 'Next',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageIndex) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentPage == pageIndex ? Colors.blue : Colors.grey[300],
      ),
    );
  }

  Widget _buildFirstAddressForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address*',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Street',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No*',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _houseNumberController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '123',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'City*',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'City name',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 32),
          Text(
            '* Required fields',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondAddressForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Postal Code*',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Post code',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),
            const Text(
              'Province',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _provinceController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Province name',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Country',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _countryController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Country name',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _houseNumberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
