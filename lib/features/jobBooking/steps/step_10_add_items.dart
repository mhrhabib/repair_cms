import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/job_create_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/jobItem/job_item_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/job_item_model.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 10 – Add Items (Protection case, Insurance, etc.)
/// This step ALSO triggers the initial Job Creation via JobCreateCubit.
class StepAddItemsWidget extends StatefulWidget {
  const StepAddItemsWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.onJobCreated,
  });

  final void Function(bool canProceed) onCanProceedChanged;
  final void Function(String jobId) onJobCreated;

  @override
  State<StepAddItemsWidget> createState() => StepAddItemsWidgetState();
}

class StepAddItemsWidgetState extends State<StepAddItemsWidget> {
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _itemFocusNode = FocusNode();
  final Map<String, Item> _selectedItems = {};
  bool _isCreatingJob = false;

  @override
  void initState() {
    super.initState();
    // Items are optional, so we can always proceed to "Create Job"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Items are optional, always can proceed
      widget.onCanProceedChanged(true);

      // Restore state if possible
      final state = context.read<JobBookingCubit>().state;
      if (state is JobBookingData) {
        if (state.job.assignedItemsIds.isNotEmpty) {
          // Ideally we'd fetch item details here to populate _selectedItems
          // For now, at least we know they are in the Cubit.
        }
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      final userId = storage.read('userId');
      if (userId != null) {
        context.read<JobItemCubit>().searchItems(
          userId: userId,
          keyword: query,
        );
      }
    } else {
      context.read<JobItemCubit>().clearSearch();
    }
  }

  void _addItem(Item item) {
    final cubit = context.read<JobBookingCubit>();
    if (!cubit.isItemAssigned(item.sId!)) {
      cubit.addItem(item.sId!);
      setState(() {
        _selectedItems[item.sId!] = item;
      });
    }
    _itemController.clear();
    _itemFocusNode.unfocus();
    context.read<JobItemCubit>().clearSearch();
  }

  void _removeItem(String itemId) {
    context.read<JobBookingCubit>().removeItem(itemId);
    setState(() {
      _selectedItems.remove(itemId);
    });
  }

  /// Exposed for wizard navigation - This TRRIGERS the Job Creation
  Future<bool> validate() async {
    final jobBookingState = context.read<JobBookingCubit>().state;
    if (jobBookingState is! JobBookingData) {
      showCustomToast('Missing job information', isError: true);
      return false;
    }

    setState(() => _isCreatingJob = true);

    // Generate draft status
    final userName = storage.read('fullName') ?? 'User';
    context.read<JobBookingCubit>().generateJobStatus(userName);

    try {
      final jobRequest = context.read<JobBookingCubit>().getCreateJobRequest();
      context.read<JobCreateCubit>().createJob(request: jobRequest);
      return false; // Wait for JobCreateCubit listener in build()
    } catch (e) {
      showCustomToast('Error preparing job: $e', isError: true);
      setState(() => _isCreatingJob = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCreateCubit, JobCreateState>(
      listener: (context, state) {
        if (state is JobCreateCreated) {
          final jobId = state.response.data?.sId;
          if (state.response.data != null) {
            context.read<JobBookingCubit>().updateJobFromResponse(
              state.response.data!,
            );
            if (jobId != null) {
              context.read<JobBookingCubit>().setJobId(jobId);
              widget.onJobCreated(jobId);
            }
          }
          setState(() => _isCreatingJob = false);
        } else if (state is JobCreateError) {
          showCustomToast(
            'Failed to create job: ${state.message}',
            isError: true,
          );
          setState(() => _isCreatingJob = false);
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
                        stepNumber: 10,
                        title: 'Add Items',
                        subTitle: '(Protection case, Insurance...)',
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: TextField(
                    controller: _itemController,
                    focusNode: _itemFocusNode,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.roboto(
                      fontSize: 32.sp,
                      color: AppColors.fontMainColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Answer here',
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 32.sp,
                        color: const Color(0xFFB2B5BE),
                      ),
                      // prefixIcon: Padding(
                      //   padding: EdgeInsets.only(right: 12.w),
                      //   child: Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 40.sp),
                      // ),
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.fontMainColor,
                        size: 32.sp,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildSearchResults(),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildSelectedItemsList(),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(),
              ),
            ],
          ),
          if (_isCreatingJob) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<JobItemCubit, JobItemState>(
      builder: (context, state) {
        if (state is JobItemLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is JobItemError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Center(
                child: Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16.sp,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is JobItemNoResults) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Center(
                child: Text(
                  'No items found for "${state.searchQuery}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16.sp,
                    color: AppColors.lightFontColor,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is JobItemLoaded &&
            state.itemsResponse.items != null &&
            state.itemsResponse.items!.isNotEmpty) {
          final items = state.itemsResponse.items!;
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.h),
                  itemBuilder: (ctx, index) {
                    final item = items[index];
                    final query = _itemController.text;
                    final isFirst = index == 0;

                    return InkWell(
                      onTap: () => _addItem(item),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isFirst
                                ? AppColors.primary
                                : Colors.grey.withValues(alpha: 0.2),
                          ),
                          color: isFirst
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _highlightText(
                                item.productName ?? '',
                                query,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.salePriceIncVat?.toStringAsFixed(2) ?? '0.00'} €',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'incl. ${item.vatPercent ?? 20}% VAT',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12.sp,
                                    color: AppColors.lightFontColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.fontMainColor,
        ),
      );
    }
    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: const Color(0xFFFFF176),
            color: Colors.black,
          ),
        ),
      );
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return RichText(
      text: TextSpan(
        style: GoogleFonts.roboto(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.fontMainColor,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildSelectedItemsList() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedItems.isNotEmpty) ...[
              Text('Selected Items', style: AppTypography.fontSize16),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedItems.values
                    .map(
                      (item) => Chip(
                        label: Text(item.productName ?? ''),
                        onDeleted: () => _removeItem(item.sId!),
                        deleteIconColor: Colors.red,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
