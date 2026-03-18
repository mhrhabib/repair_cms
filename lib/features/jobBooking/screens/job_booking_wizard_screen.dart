// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/models/business_model.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart';
import 'package:repair_cms/features/jobBooking/screens/job_receipt_preview_screen.dart';
import 'package:repair_cms/features/jobBooking/screens/job_thermal_receipt_preview_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import 'package:repair_cms/features/jobBooking/widgets/job_booking_top_bar.dart';

// Import All Step Widgets
import 'package:repair_cms/features/jobBooking/steps/step_01_brand.dart';
import 'package:repair_cms/features/jobBooking/steps/step_02_model.dart';
import 'package:repair_cms/features/jobBooking/steps/step_03_accessories.dart';
import 'package:repair_cms/features/jobBooking/steps/step_04_imei.dart';
import 'package:repair_cms/features/jobBooking/steps/step_05_security.dart';
import 'package:repair_cms/features/jobBooking/steps/step_06_contact.dart';
import 'package:repair_cms/features/jobBooking/steps/step_07_address.dart';
import 'package:repair_cms/features/jobBooking/steps/step_08_job_type.dart';
import 'package:repair_cms/features/jobBooking/steps/step_09_problem.dart';
import 'package:repair_cms/features/jobBooking/steps/step_10_add_items.dart';
import 'package:repair_cms/features/jobBooking/steps/step_11_file_upload.dart';
import 'package:repair_cms/features/jobBooking/steps/step_12_location.dart';
import 'package:repair_cms/features/jobBooking/steps/step_13_signature.dart';
import 'package:repair_cms/features/jobBooking/steps/step_14_printer.dart';

class JobBookingWizardScreen extends StatefulWidget {
  const JobBookingWizardScreen({super.key});

  @override
  State<JobBookingWizardScreen> createState() => _JobBookingWizardScreenState();
}

class _JobBookingWizardScreenState extends State<JobBookingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 14;
  bool _canProceed = false;

  // Global keys for steps that have "validate" methods
  late List<GlobalKey> _stepKeys;

  // Inter-step State
  String? _jobId;
  bool _isNewProfile = false;
  Customersorsuppliers? _selectedProfile;
  String? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _stepKeys = List.generate(_totalSteps, (_) => GlobalKey());
  }

  void _onCanProceedChanged(bool can) {
    if (mounted && _canProceed != can) {
      setState(() => _canProceed = can);
    }
  }

  Future<void> _handleNext() async {
    final currentKey = _stepKeys[_currentStep];
    final state = currentKey.currentState;

    // Use dynamic validation if the step provides it
    bool success = true;
    if (state != null) {
      if (state is StepBrandWidgetState)
        success = state.validate();
      else if (state is StepModelWidgetState)
        success = state.validate();
      else if (state is StepAccessoriesWidgetState)
        success = state.validate();
      else if (state is StepImeiWidgetState)
        success = state.validate();
      else if (state is StepSecurityWidgetState)
        success = state.validate();
      else if (state is StepContactWidgetState)
        success = await state.validate();
      else if (state is StepAddressWidgetState)
        success = await state.validate();
      else if (state is StepJobTypeWidgetState)
        success = state.validate();
      else if (state is StepProblemWidgetState)
        success = state.validate();
      else if (state is StepAddItemsWidgetState)
        success = await state.validate();
      else if (state is StepFileUploadWidgetState)
        success = await state.validate();
      else if (state is StepLocationWidgetState)
        success = state.validate();
      else if (state is StepSignatureWidgetState)
        success = await state.validate();
      else if (state is StepPrinterWidgetState)
        success = await state.validate();
    }

    if (success && _currentStep < _totalSteps - 1) {
      _nextPage();
    }
  }

  void _nextPage({int steps = 1}) {
    _pageController.animateToPage(
      _currentStep + steps,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep += steps;
      _canProceed = false; // Reset for next step
    });
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep -= 1;
        _canProceed = true; // Assume previous step was valid
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // Callback Handlers for Complex Steps
  void _onProfileSelected(Customersorsuppliers? profile, bool isNew) {
    setState(() {
      _selectedProfile = profile;
      _isNewProfile = isNew;
    });
    // Removed direct _nextPage() call to allow user to verify profile info in Step 6 form
  }

  void _onJobCreated(String jobId) {
    setState(() {
      _jobId = jobId;
    });
    _nextPage();
  }

  void _onJobBooked(String printerType, CreateJobResponse response) {
    // Final navigation to receipt preview based on what was selected
    if (printerType == 'Thermal Receipt') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobThermalReceiptPreviewScreen(
            jobResponse: response,
            printOption: printerType,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobReceiptPreviewScreen(
            jobResponse: response,
            printOption: printerType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            JobBookingTopBar(
              padding: 2,
              stepNumber: _currentStep + 1,
              onBack: _prevPage,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Control via buttons
                children: [
                  StepBrandWidget(
                    key: _stepKeys[0],
                    onCanProceedChanged: _onCanProceedChanged,
                    onBrandSelected: (id, name) {
                      setState(() => _selectedBrandId = id);
                    },
                  ),
                  StepModelWidget(
                    key: _stepKeys[1],
                    brandId: _selectedBrandId ?? '',
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepAccessoriesWidget(
                    key: _stepKeys[2],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepImeiWidget(
                    key: _stepKeys[3],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepSecurityWidget(
                    key: _stepKeys[4],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepContactWidget(
                    key: _stepKeys[5],
                    onCanProceedChanged: _onCanProceedChanged,
                    onProfileSelected: _onProfileSelected,
                  ),
                  StepAddressWidget(
                    key: _stepKeys[6],
                    onCanProceedChanged: _onCanProceedChanged,
                    isNewProfile: _isNewProfile,
                    selectedProfile: _selectedProfile,
                    onSuccess: _nextPage,
                  ),
                  StepJobTypeWidget(
                    key: _stepKeys[7],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepProblemWidget(
                    key: _stepKeys[8],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepAddItemsWidget(
                    key: _stepKeys[9],
                    onCanProceedChanged: _onCanProceedChanged,
                    onJobCreated: _onJobCreated,
                  ),
                  StepFileUploadWidget(
                    key: _stepKeys[10],
                    onCanProceedChanged: _onCanProceedChanged,
                    jobId: _jobId ?? '',
                    onSuccess: _nextPage,
                  ),
                  StepLocationWidget(
                    key: _stepKeys[11],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepSignatureWidget(
                    key: _stepKeys[12],
                    onCanProceedChanged: _onCanProceedChanged,
                  ),
                  StepPrinterWidget(
                    key: _stepKeys[13],
                    onCanProceedChanged: _onCanProceedChanged,
                    jobId: _jobId ?? '',
                    onJobBooked: _onJobBooked,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: BottomButtonsGroup(
                onPressed: _canProceed ? _handleNext : null,
                onBack: _prevPage,
                okButtonText: (_currentStep == 13 ? 'Finish' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
