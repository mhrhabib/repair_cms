// ignore_for_file: use_build_context_synchronously

import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/features/jobReceipt/cubits/job_receipt_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/model/models_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/models_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import '../three/job_booking_accessories_screen.dart';

class JobBookingDeviceModelScreen extends StatefulWidget {
  final String brandId;
  const JobBookingDeviceModelScreen({super.key, required this.brandId});

  @override
  State<JobBookingDeviceModelScreen> createState() => _JobBookingDeviceModelScreenState();
}

class _JobBookingDeviceModelScreenState extends State<JobBookingDeviceModelScreen> {
  String _selectedModel = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late String _userId;
  bool _isAddingModel = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _userId = _getUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModelsCubit>().getModels(brandId: widget.brandId);
      _fetchCompanyInfoAndReceipt();
    });
  }

  void _fetchCompanyInfoAndReceipt() {
    final storage = GetStorage();
    final companyId = storage.read('companyId');
    final userId = storage.read('userId');

    if (companyId != null && companyId.isNotEmpty) {
      debugPrint('🏢 [DeviceModel] Fetching company info for ID: $companyId');
      context.read<CompanyCubit>().getCompanyInfo(companyId: companyId);
    } else {
      debugPrint('⚠️ [DeviceModel] No company ID found in storage');
    }

    if (userId != null && userId.isNotEmpty) {
      debugPrint('📄 [DeviceModel] Fetching job receipt for user ID: $userId');
      context.read<JobReceiptCubit>().getJobReceipt(userId: userId);
    } else {
      debugPrint('⚠️ [DeviceModel] No user ID found in storage');
    }
  }

  String _getUserId() {
    return '64106cddcfcedd360d7096cc';
  }

  void _onFocusChange() {}

  void _selectModel(String modelName, String modelId) {
    setState(() {
      _selectedModel = modelName;
      _searchController.text = modelName;
    });
    context.read<JobBookingCubit>().updateDeviceInfo(model: modelName);

    // Update receipt footer with company info when model is selected
    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanyLoaded) {
      debugPrint('🏢 [DeviceModel] Company loaded, updating receipt footer');
      context.read<JobBookingCubit>().updateReceiptFooterFromCompany(companyState.company);
    }

    // Update receipt data (salutation and terms)
    final jobReceiptState = context.read<JobReceiptCubit>().state;
    if (jobReceiptState is JobReceiptLoaded) {
      debugPrint('📄 [DeviceModel] Job receipt loaded, updating receipt data');
      final storage = GetStorage();
      storage.write('jobReceiptData', {
        'salutation': jobReceiptState.receipt.salutation,
        'termsAndConditions': jobReceiptState.receipt.termsAndConditions,
      });
      context.read<JobBookingCubit>().updateReceiptData();
    }
  }

  Future<void> _addNewModel(String modelName) async {
    setState(() => _isAddingModel = true);

    await context.read<ModelsCubit>().createModel(name: modelName, userId: _userId, brandId: widget.brandId);

    final state = context.read<ModelsCubit>().state;
    if (state is ModelsLoaded) {
      final newModel = state.models.firstWhere(
        (model) => model.name?.toLowerCase() == modelName.toLowerCase(),
        orElse: () => ModelsModel(),
      );
      _selectModel(modelName, newModel.sId ?? '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Model "$modelName" added successfully!'), backgroundColor: Colors.green));
    } else if (state is ModelsError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add model: ${state.message}'), backgroundColor: Colors.red));
    }

    setState(() => _isAddingModel = false);
  }

  void _resetLocalChanges() {
    if (!mounted) return;
    setState(() {
      _selectedModel = '';
      _isAddingModel = false;
      _searchController.clear();
    });

    try {
      context.read<JobBookingCubit>().updateDeviceInfo(model: '');
    } catch (_) {}
  }

  void _handleBack() {
    _resetLocalChanges();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetLocalChanges();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12.h,
                      width: MediaQuery.of(context).size.width * .071 * 2,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(0),
                        ),
                        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _handleBack,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF71788F),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 42.w,
                          height: 42.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Center(
                            child: Text('2', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      Text('Enter the device Model', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                      SizedBox(height: 4.h),

                      Text(
                        '(E.g. iPhone 16, Galaxy S24)',
                        style: AppTypography.fontSize22.copyWith(fontWeight: FontWeight.normal),
                      ),

                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),

              // Dropdown section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: BlocBuilder<ModelsCubit, ModelsState>(
                    builder: (context, state) {
                      if (state is ModelsLoading) {
                        return SizedBox(
                          height: 60.h,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is ModelsError) {
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Failed to load models',
                                style: AppTypography.fontSize14.copyWith(color: Colors.red),
                              ),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () => context.read<ModelsCubit>().getModels(brandId: widget.brandId),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is ModelsLoaded || state is ModelsSearchResult) {
                        final models = state is ModelsLoaded ? state.models : (state as ModelsSearchResult).models;
                        final allModels = state is ModelsLoaded
                            ? state.models
                            : (state as ModelsSearchResult).allModels;

                        return CustomDropdownSearch<ModelsModel>(
                          controller: _searchController,
                          items: models,
                          hintText: 'Search and select model...',
                          noItemsText: 'No models found',
                          displayAllSuggestionWhenTap: true,
                          isMultiSelectDropdown: false,
                          onSuggestionSelected: (model) async {
                            if (model.sId == null && model.name?.startsWith('Add "') == true) {
                              final modelName = model.name?.split('"')[1] ?? '';
                              if (modelName.isNotEmpty) {
                                await _addNewModel(modelName);
                              }
                            } else {
                              _selectModel(model.name ?? 'Unknown Model', model.sId ?? '');
                            }
                          },
                          itemBuilder: (context, model) {
                            final isNewOption = model.sId == null && model.name?.startsWith('Add "') == true;

                            if (isNewOption) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        model.name?.split('"')[1] ?? '',
                                        style: AppTypography.fontSize16.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'NEW',
                                          style: AppTypography.fontSize12.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: _selectedModel == model.name ? const Color(0xFFFFF59D) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ListTile(
                                title: Text(
                                  model.name ?? 'Unknown Model',
                                  style: AppTypography.fontSize16.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                          suggestionsCallback: (pattern) {
                            if (pattern.isEmpty) return allModels;

                            final filteredModels = allModels
                                .where((model) => (model.name ?? '').toLowerCase().contains(pattern.toLowerCase()))
                                .toList();

                            final exactMatch = filteredModels.any(
                              (model) => model.name?.toLowerCase() == pattern.toLowerCase(),
                            );

                            if (!exactMatch && pattern.isNotEmpty) {
                              filteredModels.insert(0, ModelsModel(sId: null, name: 'Add "$pattern" as new model'));
                            }

                            return filteredModels;
                          },
                        );
                      }

                      return CustomDropdownSearch<ModelsModel>(
                        controller: _searchController,
                        items: [],
                        hintText: 'Loading models...',
                        noItemsText: 'No models available',
                        displayAllSuggestionWhenTap: false,
                        isMultiSelectDropdown: false,
                        onSuggestionSelected: (model) {},
                        itemBuilder: (context, model) => ListTile(title: Text(model.name ?? 'Unknown')),
                        suggestionsCallback: (pattern) => [],
                      );
                    },
                  ),
                ),
              ),

              // Show selected model info
              BlocBuilder<JobBookingCubit, JobBookingState>(
                builder: (context, bookingState) {
                  final deviceModel = bookingState is JobBookingData ? bookingState.device.model : '';

                  if (deviceModel.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Model',
                                      style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      deviceModel,
                                      style: AppTypography.fontSize16Bold.copyWith(color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedModel = '';
                                    _searchController.clear();
                                  });
                                  context.read<JobBookingCubit>().updateDeviceInfo(model: '');
                                },
                                child: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Show adding indicator
              if (_isAddingModel)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8.w),
                        Text('Adding model...', style: AppTypography.fontSize14.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

              // Show models count
              BlocBuilder<ModelsCubit, ModelsState>(
                builder: (context, state) {
                  if (state is ModelsLoaded && state.models.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          '${state.models.length} models available',
                          style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
            ],
          ),
        ),

        bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
          builder: (context, bookingState) {
            final hasSelectedModel = bookingState is JobBookingData && bookingState.device.model.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8.h, left: 24.w, right: 24.w),
              child: BottomButtonsGroup(
                onPressed: hasSelectedModel
                    ? () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (context) => JobBookingAccessoriesScreen()));
                      }
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure cubit device info is cleared when leaving this screen
    try {
      context.read<JobBookingCubit>().updateDeviceInfo(model: '');
    } catch (_) {}

    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
