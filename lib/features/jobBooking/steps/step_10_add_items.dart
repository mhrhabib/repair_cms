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
      widget.onCanProceedChanged(true);
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
                    TitleWidget(
                      stepNumber: 10,
                      title: 'Add Items',
                      subTitle: '(Protection case, Insurance...)',
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
                    decoration: InputDecoration(
                      hintText: 'Search items by name...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
        if (state is JobItemLoading)
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        if (state is JobItemLoaded) {
          return SliverList(
            delegate: SliverChildBuilderDelegate((ctx, index) {
              final item = state.itemsResponse.items![index];
              return ListTile(
                title: Text(item.productName ?? ''),
                subtitle: Text(
                  '${item.salePriceIncVat?.toStringAsFixed(2) ?? '0.00'} €',
                ),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () => _addItem(item),
              );
            }, childCount: state.itemsResponse.items!.length),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
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
