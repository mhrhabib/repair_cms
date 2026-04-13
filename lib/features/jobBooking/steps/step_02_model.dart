// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/core/utils/widgets/custom_dropdown_search_field.dart';
import 'package:repair_cms/core/utils/widgets/shimmer_loader.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';
import 'package:repair_cms/features/jobReceipt/cubits/job_receipt_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/model/models_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/models_model.dart';

class StepModelWidget extends StatefulWidget {
  const StepModelWidget({super.key, required this.brandId, required this.onCanProceedChanged});

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
    _userId = storage.read('userId') ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.brandId.isNotEmpty) {
        context.read<ModelsCubit>().getModels(brandId: widget.brandId);
      }
      _fetchCompanyInfoAndReceipt();

      // Restore state from Cubit
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        final savedModel = bookingState.device.model;
        if (savedModel.isNotEmpty) {
          setState(() {
            _selectedModel = savedModel;
            _searchController.text = savedModel;
          });
          widget.onCanProceedChanged(true);
        }
      }
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
      context.read<JobBookingCubit>().updateReceiptFooterFromCompany(companyState.company);
    }

    final jobReceiptState = context.read<JobReceiptCubit>().state;
    if (jobReceiptState is JobReceiptLoaded) {
      final storage = GetStorage();
      storage.write(
        'jobReceiptData',
        jsonEncode({
          'salutation': jobReceiptState.receipt.salutation,
          'termsAndConditions': jobReceiptState.receipt.termsAndConditions,
        }),
      );
      context.read<JobBookingCubit>().updateReceiptData();
    }
  }

  Future<void> _addNewModel(String modelName) async {
    setState(() => _isAddingModel = true);

    await context.read<ModelsCubit>().createModel(name: modelName, userId: _userId, brandId: widget.brandId);

    if (!mounted) return;

    final state = context.read<ModelsCubit>().state;
    if (state is ModelsLoaded) {
      final newModel = state.models.firstWhere(
        (model) => model.name?.toLowerCase() == modelName.toLowerCase(),
        orElse: () => ModelsModel(),
      );
      _selectModel(modelName, newModel.sId ?? '');
      SnackbarDemo(message: 'Model "$modelName" added successfully!').showCustomSnackbar(context);
    } else if (state is ModelsError) {
      SnackbarDemo(message: 'Failed to add model: ${state.message}').showCustomSnackbar(context);
    }

    setState(() => _isAddingModel = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ModelsCubit, ModelsState>(
      listener: (context, state) {
        if (state is ModelsLoaded || state is ModelsSearchResult) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _searchFocusNode.requestFocus();
            }
          });
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24.h),
                  TitleWidget(stepNumber: 2, title: 'Enter the device Model', subTitle: '(E.g. iPhone 16, Galaxy S24)'),
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
                  if (state is ModelsLoading && _selectedModel.isEmpty) {
                    return SizedBox(
                      height: 60.h,
                      child: Center(child: ShimmerLoader()),
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
                          Text('Failed to load models', style: AppTypography.fontSize14.copyWith(color: Colors.red)),
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
                    final allModels = state is ModelsLoaded ? state.models : (state as ModelsSearchResult).allModels;

                    return CustomDropdownSearch<ModelsModel>(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      items: models,
                      hintText: 'Answer here',
                      noItemsText: 'No models found',
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                      showSuggestionsWhenEmpty: false,
                      suggestionsBoxColor: AppColors.whiteColor,
                      onSuggestionSelected: (model) async {
                        if (model.sId == null && model.name?.startsWith('Add "') == true) {
                          final modelName = model.name?.split('"')[1] ?? '';
                          if (modelName.isNotEmpty) await _addNewModel(modelName);
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
                                    style: GoogleFonts.roboto(fontSize: 20.sp, color: AppColors.fontMainColor),
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
                            title: CustomDropdownSearch.highlightedText(
                              text: model.name ?? 'Unknown Model',
                              query: _searchController.text,
                              style: TextStyle(fontSize: 20.sp, color: AppColors.fontMainColor),
                            ),
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        if (pattern.isEmpty) return [];
                        final filtered = allModels
                            .where((m) => (m.name ?? '').toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                        final exactMatch = filtered.any((m) => m.name?.toLowerCase() == pattern.toLowerCase());
                        if (!exactMatch && pattern.isNotEmpty) {
                          filtered.insert(0, ModelsModel(sId: null, name: 'Add "$pattern" as new model'));
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
                    itemBuilder: (context, model) => ListTile(title: Text(model.name ?? 'Unknown')),
                    suggestionsCallback: (pattern) => [],
                  );
                },
              ),
            ),
          ),

          if (_isAddingModel)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 16.w, height: 16.h, child: CupertinoActivityIndicator(radius: 8.r)),
                    SizedBox(width: 8.w),
                    Text('Adding model...', style: AppTypography.fontSize14.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
