// ignore_for_file: use_build_context_synchronously

import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';
import 'package:repair_cms/features/jobReceipt/cubits/job_receipt_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/model/models_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/models_model.dart';

class StepModelWidget extends StatefulWidget {
  const StepModelWidget({
    super.key,
    required this.brandId,
    required this.onCanProceedChanged,
  });

  final String brandId;
  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepModelWidget> createState() => StepModelWidgetState();
}

class StepModelWidgetState extends State<StepModelWidget> {
  String _selectedModel = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late String _userId;
  bool _isAddingModel = false;

  bool validate() {
    if (_selectedModel.isNotEmpty) return true;
    showCustomToast('Please select or add a model', isError: true);
    return false;
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {});
    _userId = '64106cddcfcedd360d7096cc';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.brandId.isNotEmpty) {
        context.read<ModelsCubit>().getModels(brandId: widget.brandId);
      }
      _fetchCompanyInfoAndReceipt();
    });
  }

  @override
  void didUpdateWidget(StepModelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.brandId != oldWidget.brandId && widget.brandId.isNotEmpty) {
      context.read<ModelsCubit>().getModels(brandId: widget.brandId);
    }
  }

  void _fetchCompanyInfoAndReceipt() {
    final storage = GetStorage();
    final companyId = storage.read('companyId');
    final userId = storage.read('userId');

    if (companyId != null && companyId.isNotEmpty) {
      context.read<CompanyCubit>().getCompanyInfo(companyId: companyId);
    }
    if (userId != null && userId.isNotEmpty) {
      context.read<JobReceiptCubit>().getJobReceipt(userId: userId);
    }
  }

  void _selectModel(String modelName, String modelId) {
    setState(() {
      _selectedModel = modelName;
      _searchController.text = modelName;
    });
    context.read<JobBookingCubit>().updateDeviceInfo(model: modelName);
    widget.onCanProceedChanged(modelName.isNotEmpty);

    final companyState = context.read<CompanyCubit>().state;
    if (companyState is CompanyLoaded) {
      context.read<JobBookingCubit>().updateReceiptFooterFromCompany(
        companyState.company,
      );
    }

    final jobReceiptState = context.read<JobReceiptCubit>().state;
    if (jobReceiptState is JobReceiptLoaded) {
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

    await context.read<ModelsCubit>().createModel(
      name: modelName,
      userId: _userId,
      brandId: widget.brandId,
    );

    if (!mounted) return;

    final state = context.read<ModelsCubit>().state;
    if (state is ModelsLoaded) {
      final newModel = state.models.firstWhere(
        (model) => model.name?.toLowerCase() == modelName.toLowerCase(),
        orElse: () => ModelsModel(),
      );
      _selectModel(modelName, newModel.sId ?? '');
      SnackbarDemo(
        message: 'Model "$modelName" added successfully!',
      ).showCustomSnackbar(context);
    } else if (state is ModelsError) {
      SnackbarDemo(
        message: 'Failed to add model: ${state.message}',
      ).showCustomSnackbar(context);
    }

    setState(() => _isAddingModel = false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                TitleWidget(
                  stepNumber: 2,
                  title: 'Enter the device Model',
                  subTitle: '(E.g. iPhone 16, Galaxy S24)',
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),

        // Dropdown
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
                          style: AppTypography.fontSize14.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ModelsCubit>()
                              .getModels(brandId: widget.brandId),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ModelsLoaded || state is ModelsSearchResult) {
                  final models = state is ModelsLoaded
                      ? state.models
                      : (state as ModelsSearchResult).models;
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
                      if (model.sId == null &&
                          model.name?.startsWith('Add "') == true) {
                        final modelName = model.name?.split('"')[1] ?? '';
                        if (modelName.isNotEmpty) await _addNewModel(modelName);
                      } else {
                        _selectModel(
                          model.name ?? 'Unknown Model',
                          model.sId ?? '',
                        );
                      }
                    },
                    itemBuilder: (context, model) {
                      final isNewOption =
                          model.sId == null &&
                          model.name?.startsWith('Add "') == true;
                      if (isNewOption) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
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
                          color: _selectedModel == model.name
                              ? const Color(0xFFFFF59D)
                              : Colors.transparent,
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
                      final filtered = allModels
                          .where(
                            (m) => (m.name ?? '').toLowerCase().contains(
                              pattern.toLowerCase(),
                            ),
                          )
                          .toList();
                      final exactMatch = filtered.any(
                        (m) => m.name?.toLowerCase() == pattern.toLowerCase(),
                      );
                      if (!exactMatch && pattern.isNotEmpty) {
                        filtered.insert(
                          0,
                          ModelsModel(
                            sId: null,
                            name: 'Add "$pattern" as new model',
                          ),
                        );
                      }
                      return filtered;
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
                  itemBuilder: (context, model) =>
                      ListTile(title: Text(model.name ?? 'Unknown')),
                  suggestionsCallback: (pattern) => [],
                );
              },
            ),
          ),
        ),

        // Selected model
        // BlocBuilder<JobBookingCubit, JobBookingState>(
        //   builder: (context, bookingState) {
        //     final deviceModel = bookingState is JobBookingData
        //         ? bookingState.device.model
        //         : '';
        //     if (deviceModel.isNotEmpty) {
        //       return SliverToBoxAdapter(
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(
        //             horizontal: 24.w,
        //             vertical: 16.h,
        //           ),
        //           child: Container(
        //             padding: EdgeInsets.all(16.w),
        //             decoration: BoxDecoration(
        //               color: AppColors.primary.withValues(alpha: 0.1),
        //               borderRadius: BorderRadius.circular(12.r),
        //               border: Border.all(color: AppColors.primary),
        //             ),
        //             child: Row(
        //               children: [
        //                 Icon(
        //                   Icons.check_circle,
        //                   color: AppColors.primary,
        //                   size: 20.sp,
        //                 ),
        //                 SizedBox(width: 12.w),
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Text(
        //                         'Selected Model',
        //                         style: AppTypography.fontSize12.copyWith(
        //                           color: Colors.grey.shade600,
        //                         ),
        //                       ),
        //                       Text(
        //                         deviceModel,
        //                         style: AppTypography.fontSize16Bold.copyWith(
        //                           color: AppColors.primary,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: () {
        //                     setState(() {
        //                       _selectedModel = '';
        //                       _searchController.clear();
        //                     });
        //                     context.read<JobBookingCubit>().updateDeviceInfo(
        //                       model: '',
        //                     );
        //                     widget.onCanProceedChanged(false);
        //                   },
        //                   child: Icon(
        //                     Icons.close,
        //                     color: Colors.grey,
        //                     size: 20.sp,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //     }
        //     return const SliverToBoxAdapter(child: SizedBox.shrink());
        //   },
        // ),
        if (_isAddingModel)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Adding model...',
                    style: AppTypography.fontSize14.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

        BlocBuilder<ModelsCubit, ModelsState>(
          builder: (context, state) {
            if (state is ModelsLoaded && state.models.isNotEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    '${state.models.length} models available',
                    style: AppTypography.fontSize12.copyWith(
                      color: Colors.grey.shade600,
                    ),
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
