import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/contactType/contact_type_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/profile/models/profile_response_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

/// Step 7 – Address Details (Manual entry or prefilled from profile)
class StepAddressWidget extends StatefulWidget {
  const StepAddressWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.isNewProfile,
    this.selectedProfile,
    required this.onSuccess,
  });

  final void Function(bool canProceed) onCanProceedChanged;
  final bool isNewProfile;
  final Customersorsuppliers? selectedProfile;
  final VoidCallback onSuccess;

  @override
  State<StepAddressWidget> createState() => StepAddressWidgetState();
}

class StepAddressWidgetState extends State<StepAddressWidget> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  // final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String selectedPhoneCode = '+1';
  final countryPicker = const FlCountryCodePicker();

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _hasHandledContactSuccess = false;

  // Original values to detect changes
  String _originalStreet = '';
  String _originalAddress2 = '';
  // String _originalHouseNumber = '';
  String _originalCity = '';
  String _originalPostalCode = '';
  String _originalProvince = '';
  String _originalCountry = '';

  @override
  void initState() {
    super.initState();
    _countryController.text = "";

    // Pre-select country from SaaS Profile
    final userData = storage.read('user');
    if (userData != null) {
      try {
        UserData user;
        if (userData is String) {
          user = UserData.fromJson(jsonDecode(userData));
        } else {
          user = UserData.fromJson(userData);
        }

        final country = user.location?.country;
        if (country != null && country.toString().trim().isNotEmpty) {
          _countryController.text = country.toString().trim();
          debugPrint(
            'StepAddressWidget - Pre-selected Country: ${_countryController.text}',
          );
          _syncOriginals();
        }
      } catch (e) {
        debugPrint(
          'StepAddressWidget - Error loading SaaS profile for country: $e',
        );
      }
    }

    if (!widget.isNewProfile && widget.selectedProfile != null) {
      _loadExistingProfileAddressData();
    } else if (widget.isNewProfile &&
        (context.read<JobBookingCubit>().state as JobBookingData)
            .contact
            .shippingAddress
            .street!
            .isEmpty) {
      // Ensure we start with empty fields for a new profile if the cubit was just cleared
      _syncOriginals();
    } else {
      _loadExistingAddressDataFromJobBooking();
    }

    _loadExistingPhoneData();

    _addChangeListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(_isFormValid);
    });
  }

  void _addChangeListeners() {
    void checkForChanges() {
      final hasChanges =
          _addressController.text != _originalStreet ||
          _address2Controller.text != _originalAddress2 ||
          // _houseNumberController.text != _originalHouseNumber ||
          _cityController.text != _originalCity ||
          _postalCodeController.text != _originalPostalCode ||
          _provinceController.text != _originalProvince ||
          _countryController.text != _originalCountry;

      if (mounted) {
        setState(() => _hasChanges = hasChanges);
        widget.onCanProceedChanged(_isFormValid);
      }
    }

    _addressController.addListener(checkForChanges);
    _address2Controller.addListener(checkForChanges);
    // _houseNumberController.addListener(checkForChanges);
    _cityController.addListener(checkForChanges);
    _postalCodeController.addListener(checkForChanges);
    _provinceController.addListener(checkForChanges);
    _countryController.addListener(checkForChanges);
  }

  void _loadExistingProfileAddressData() {
    final contactTypeCubit = context.read<ContactTypeCubit>();
    final shippingAddress = contactTypeCubit.getPrimaryShippingAddress(
      widget.selectedProfile!,
    );
    if (shippingAddress != null) {
      _addressController.text = shippingAddress.street ?? '';
      _address2Controller.text = shippingAddress.address2 ?? '';
      // _houseNumberController.text = shippingAddress.iV?.toString() ?? '';
      _cityController.text = shippingAddress.city ?? '';
      _postalCodeController.text = shippingAddress.zip ?? '';
      _provinceController.text =
          shippingAddress.city ?? ''; // Assuming city as province if missing
      _countryController.text = shippingAddress.country ?? "";
      _syncOriginals();
    }
  }

  void _loadExistingAddressDataFromJobBooking() {
    final state = context.read<JobBookingCubit>().state;
    if (state is JobBookingData) {
      final sa = state.contact.shippingAddress;
      _addressController.text = sa.street ?? '';
      _address2Controller.text = sa.address2 ?? '';
      // _houseNumberController.text = sa.no ?? '';
      _cityController.text = sa.city ?? '';
      _postalCodeController.text = sa.zip ?? '';
      _provinceController.text = sa.state ?? '';
      _countryController.text = sa.country ?? '';
      _syncOriginals();
    }
  }

  void _syncOriginals() {
    _originalStreet = _addressController.text;
    _originalAddress2 = _address2Controller.text;
    // _originalHouseNumber = _houseNumberController.text;
    _originalCity = _cityController.text;
    _originalPostalCode = _postalCodeController.text;
    _originalProvince = _provinceController.text;
    _originalCountry = _countryController.text;
  }

  void _loadExistingPhoneData() {
    final state = context.read<JobBookingCubit>().state;
    if (state is JobBookingData) {
      final contact = state.contact;
      _phoneController.text = contact.telephone;
      if (contact.telephonePrefix.isNotEmpty) {
        selectedPhoneCode = contact.telephonePrefix;
      }
    }

    // If profile is selected, override from profile if needed
    if (!widget.isNewProfile && widget.selectedProfile != null) {
      final contactTypeCubit = context.read<ContactTypeCubit>();
      final primaryPhone = contactTypeCubit.getPrimaryPhoneNumber(
        widget.selectedProfile!,
      );
      if (primaryPhone != null) {
        _phoneController.text = primaryPhone.replaceAll(RegExp(r'[^\d+]'), '');
        selectedPhoneCode =
            _extractPhonePrefix(primaryPhone) ?? selectedPhoneCode;
      }
    }
  }

  String? _extractPhonePrefix(String? phone) {
    if (phone == null) return null;
    final match = RegExp(r'^(\+\d+)').firstMatch(phone);
    return match?.group(1);
  }

  bool get _isFormValid =>
      _addressController.text.isNotEmpty &&
      // _houseNumberController.text.isNotEmpty &&
      _cityController.text.isNotEmpty &&
      _postalCodeController.text.isNotEmpty;

  /// Exposed for wizard navigation – returns true if step logic successfully saved
  Future<bool> validate() async {
    if (!_isFormValid) {
      showCustomToast('Please fill all required address fields', isError: true);
      return false;
    }

    setState(() => _isLoading = true);
    final jobBookingCubit = context.read<JobBookingCubit>();
    final address = CustomerAddress(
      id: "",
      street: _addressController.text,
      address2: _address2Controller.text,
      // no: _houseNumberController.text,
      city: _cityController.text,
      zip: _postalCodeController.text,
      state: _provinceController.text.isNotEmpty
          ? _provinceController.text
          : 'N/A',
      country: _countryController.text,
    );

    jobBookingCubit.updateShippingAddress(address);
    jobBookingCubit.updateBillingAddress(address);
    jobBookingCubit.updateCustomerInfo(
      telephone: _phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
      telephonePrefix: selectedPhoneCode,
    );

    if (widget.isNewProfile) {
      _createProfileWithAddress();
      return false; // Wait for BlocListener success
    } else if (_hasChanges && widget.selectedProfile != null) {
      _updateProfileWithAddress();
      return false; // Wait for BlocListener success
    } else {
      setState(() => _isLoading = false);
      return true; // Already exists, just proceed
    }
  }

  void _createProfileWithAddress() {
    final contactTypeCubit = context.read<ContactTypeCubit>();
    final contact =
        (context.read<JobBookingCubit>().state as JobBookingData).contact;
    final addressData = {
      "street": _addressController.text,
      "address2": _address2Controller.text,
      // "no": _houseNumberController.text,
      "city": _cityController.text,
      "zip": _postalCodeController.text,
      "state": _provinceController.text,
      "country": _countryController.text,
      "primary": true,
    };

    final payload = contactTypeCubit.createBusinessPayload(
      type: contact.type,
      type2: contact.type2,
      firstName: contact.firstName,
      lastName: contact.lastName,
      organization: contact.organization,
      position: contact.position,
      userId: storage.read('userId') ?? '',
      location: storage.read('locationId') ?? '6568646e9c9d411a9ce57145',
      shippingAddresses: [addressData],
      billingAddresses: [addressData],
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
    contactTypeCubit.createBusiness(payload: payload);
  }

  void _updateProfileWithAddress() {
    final contactTypeCubit = context.read<ContactTypeCubit>();
    final addressData = {
      // For shipping, they might need an ID if patching existing. If missing, it might add new.
      // Often the API determines insert vs update based on the presence of _id or matching customerId.
      "_id": widget.selectedProfile!.shippingAddresses?.firstOrNull?.sId ?? "",
      "street": _addressController.text,
      "address2": _address2Controller.text,
      "city": _cityController.text,
      "zip": _postalCodeController.text,
      "state": _provinceController.text,
      "country": _countryController.text,
      "primary": true,
      "customerId": widget.selectedProfile!.sId,
    };

    final billingData = {
      "_id": widget.selectedProfile!.billingAddresses?.firstOrNull?.sId ?? "",
      "street": _addressController.text,
      "address2": _address2Controller.text,
      "city": _cityController.text,
      "zip": _postalCodeController.text,
      "state": _provinceController.text,
      "country": _countryController.text,
      "primary": true,
      "customerId": widget.selectedProfile!.sId,
    };

    contactTypeCubit.updateBusinessAddresses(
      profileId: widget.selectedProfile!.sId!,
      shippingPayload: [addressData],
      billingPayload: [billingData],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactTypeCubit, ContactTypeState>(
      listener: (context, state) {
        if (state is ContactTypeSuccess && !_hasHandledContactSuccess) {
          _hasHandledContactSuccess = true;
          if (state.createdBusiness?.sId != null) {
            final jbc = context.read<JobBookingCubit>();
            final s = jbc.state as JobBookingData;
            jbc.updateCustomerInfo(
              salutation: s.contact.salutation,
              firstName: s.contact.firstName,
              lastName: s.contact.lastName,
              telephone: s.contact.telephone,
              telephonePrefix: s.contact.telephonePrefix,
              email: s.contact.email,
              customerId: state.createdBusiness!.sId!,
            );
          }
          setState(() => _isLoading = false);
          widget.onSuccess();
        } else if (state is ContactTypeError) {
          showCustomToast('Error: ${state.message}', isError: true);
          setState(() => _isLoading = false);
        }
      },
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TitleWidget(
                        stepNumber: 7,
                        title: 'Address details',
                        subTitle: 'Enter or confirm customer address',
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: _buildAddressForm()),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildUnderlineField(
                  _addressController,
                  'Address*',
                  'Street',
                ),
              ),
              SizedBox(width: 16.w),
              // Expanded(
              //   flex: 1,
              //   child: _buildUnderlineField(
              //     _houseNumberController,
              //     'No*',
              //     '123',
              //     keyboardType: TextInputType.number,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildUnderlineField(
            _address2Controller,
            'Additional Address Information',
            'Apartment, suite, unit, etc.',
          ),
          SizedBox(height: 24.h),
          _buildUnderlineField(_cityController, 'City*', 'City name'),
          SizedBox(height: 24.h),
          _buildUnderlineField(
            _postalCodeController,
            'Postal Code*',
            'Post code',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 24.h),
          _buildUnderlineField(
            _provinceController,
            'Province',
            'Province name',
          ),
          SizedBox(height: 24.h),
          _buildUnderlineField(_countryController, 'Country', 'Country name'),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildUnderlineField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fontSize14),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: AppColors.warningColor,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.roboto(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.fontMainColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _address2Controller.dispose();
    // _houseNumberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
