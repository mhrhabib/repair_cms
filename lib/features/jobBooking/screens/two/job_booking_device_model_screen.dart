import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/enhanced_dropdown_search_field.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/model/models_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/models_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';
import '../three/job_booking_accessories_screen.dart';

class JobBookingDeviceModelScreen extends StatefulWidget {
  const JobBookingDeviceModelScreen({super.key});

  @override
  State<JobBookingDeviceModelScreen> createState() => _JobBookingDeviceModelScreenState();
}

class _JobBookingDeviceModelScreenState extends State<JobBookingDeviceModelScreen> {
  String selectedModel = '';
  String selectedModelId = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late String _brandId;
  late String _userId;
  bool _isCreatingModel = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);

    // Get user ID and brand ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userId = _getUserId();
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        setState(() {
          _brandId = _getBrandIdFromName(bookingState.device.brand);
        });

        // Load models when screen initializes
        if (_brandId.isNotEmpty) {
          context.read<ModelsCubit>().getModels(brandId: _brandId);
        }
      }
    });
  }

  String _getUserId() {
    return '64106cddcfcedd360d7096cc'; // Example user ID
  }

  String _getBrandIdFromName(String brandName) {
    // TODO: Implement logic to get brand ID from brand name
    // For now, return a placeholder - you should store the brand ID when brand is selected
    return '65f2573f56a1a8458f38b85b'; // Replace with actual implementation
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      // Handle focus loss if needed
    }
  }

  void _selectModel(String modelName, String modelId) {
    setState(() {
      selectedModel = modelName;
      selectedModelId = modelId;
      _searchController.text = modelName;
    });

    // Close the dropdown by removing focus
    _searchFocusNode.unfocus();

    // Update JobBookingCubit with selected model
    context.read<JobBookingCubit>().updateDeviceInfo(model: modelName);
  }

  Future<void> _createNewModel(String modelName) async {
    if (_brandId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a brand first'), backgroundColor: Colors.red));
      return;
    }

    if (modelName.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a model name'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isCreatingModel = true;
    });

    try {
      // Use ModelsCubit to create the model
      await context.read<ModelsCubit>().createModel(name: modelName.trim(), userId: _userId, brandId: _brandId);

      // Wait a bit for the state to update
      await Future.delayed(Duration(milliseconds: 300));

      // Get the newly created model from the updated state
      final modelsState = context.read<ModelsCubit>().state;
      String newModelId = '';

      if (modelsState is ModelsLoaded) {
        final newModel = modelsState.models.firstWhere(
          (model) => model.name?.toLowerCase() == modelName.trim().toLowerCase(),
          orElse: () => ModelsModel(),
        );
        newModelId = newModel.sId ?? '';
      }

      // Select the newly created model
      _selectModel(modelName.trim(), newModelId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Model "$modelName" created successfully'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create model: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isCreatingModel = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
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
                        onTap: () => Navigator.of(context).pop(),
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

                    // Step indicator
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

                    // Question text
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

            // Dropdown section with ModelsCubit integration
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<ModelsCubit, ModelsState>(
                  builder: (context, state) {
                    if (state is ModelsLoading) {
                      return Container(
                        height: 60.h,
                        child: const Center(child: CircularProgressIndicator()),
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
                              onPressed: () {
                                if (_brandId.isNotEmpty) {
                                  context.read<ModelsCubit>().getModels(brandId: _brandId);
                                }
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final List<ModelsModel> models = state is ModelsLoaded
                        ? state.models
                        : state is ModelsSearchResult
                        ? state.models
                        : [];

                    return EnhancedDropdownSearch<ModelsModel>(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      items: models,
                      hintText: models.isEmpty ? 'Type to create a new model...' : 'Search and select model...',
                      noItemsText: 'No models found',
                      onSuggestionSelected: (model) {
                        _selectModel(model.name ?? 'Unknown Model', model.sId ?? '');
                      },
                      itemBuilder: (context, model) => ListTile(
                        title: Text(
                          model.name ?? 'Unknown Model',
                          style: AppTypography.fontSize14.copyWith(color: Colors.black),
                        ),
                        subtitle: model.sId != null
                            ? Text('ID: ${model.sId}', style: AppTypography.fontSize12.copyWith(color: Colors.grey))
                            : null,
                      ),
                      suggestionsCallback: (pattern) {
                        if (pattern.isEmpty) {
                          return models;
                        }
                        return models
                            .where((model) => (model.name ?? '').toLowerCase().contains(pattern.toLowerCase()))
                            .toList();
                      },
                      noItemsFoundBuilder: (context, pattern) {
                        if (pattern.isNotEmpty) {
                          // Show "Create new" option when searching and no results
                          return InkWell(
                            onTap: _isCreatingModel ? null : () => _createNewModel(pattern),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      leading: Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20.sp),
                                      title: Text(
                                        'Create "$pattern"',
                                        style: AppTypography.fontSize14.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Add as new model for this brand',
                                        style: AppTypography.fontSize12.copyWith(color: Colors.grey),
                                      ),
                                    ),
                                  ),

                                  _isCreatingModel
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            'Add',
                                            style: AppTypography.fontSize14.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        }

                        // When pattern is empty and no models exist
                        if (pattern.isEmpty && models.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 32.sp),
                                SizedBox(height: 8.h),
                                Text(
                                  'No models found for this brand',
                                  style: AppTypography.fontSize14.copyWith(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Start typing to create a new model',
                                  style: AppTypography.fontSize12.copyWith(color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    );
                  },
                ),
              ),
            ),

            // Show creating state
            if (_isCreatingModel)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Creating new model...',
                            style: AppTypography.fontSize14.copyWith(color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
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
                          color: AppColors.primary.withOpacity(0.1),
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
                                  selectedModel = '';
                                  selectedModelId = '';
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
          ],
        ),
      ),

      // Fixed bottom navigation bar with keyboard handling
      bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
        builder: (context, bookingState) {
          final hasSelectedModel = bookingState is JobBookingData && bookingState.device.model.isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8.h, left: 24.w, right: 24.w),
            child: BottomButtonsGroup(
              onPressed: hasSelectedModel && !_isCreatingModel
                  ? () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => JobBookingAccessoriesScreen()));
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Selected model: ${bookingState.device.model}'),
                      //     backgroundColor: AppColors.primary,
                      //   ),
                      // );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // _searchController.dispose();
    // _searchFocusNode.dispose();
    super.dispose();
  }
}
