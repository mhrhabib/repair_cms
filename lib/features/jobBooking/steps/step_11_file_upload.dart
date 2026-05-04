import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/fileUpload/job_file_upload_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 11 – File Upload (Optional)
class StepFileUploadWidget extends StatefulWidget {
  const StepFileUploadWidget({
    super.key,
    required this.onCanProceedChanged,
    required this.jobId,
    required this.onSuccess,
  });

  final void Function(bool canProceed) onCanProceedChanged;
  final String jobId;
  final VoidCallback onSuccess;

  @override
  State<StepFileUploadWidget> createState() => StepFileUploadWidgetState();
}

class StepFileUploadWidgetState extends State<StepFileUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final Random _random = Random();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Optional step, always can proceed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged(true);
    });
  }

  Future<void> _handleCameraUpload() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        await context.read<JobBookingCubit>().processAndAddFile(image.path);
      }
    } catch (e) {
      showCustomToast('Error capturing image: $e', isError: true);
    }
  }

  Future<void> _handleGalleryUpload() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (images.isNotEmpty) {
        for (final image in images) {
          await context.read<JobBookingCubit>().processAndAddFile(image.path);
        }
      }
    } catch (e) {
      showCustomToast('Error selecting images: $e', isError: true);
    }
  }

  void _removeFile(int index) {
    context.read<JobBookingCubit>().removeFile(index);
  }

  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      24,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Exposed for wizard navigation - Uploads files before moving to next step
  Future<bool> validate() async {
    final state = context.read<JobBookingCubit>().state;
    if (state is! JobBookingData) return true;

    final files = state.job.files;
    if (files == null || files.isEmpty) return true;

    setState(() => _isUploading = true);
    final userId = storage.read('userId') ?? '';

    final fileData = files.map((f) {
      final json = f.toJson();
      if (json['id'] == null || json['id'].toString().isEmpty) {
        json['id'] = _generateRandomId();
      }
      return json;
    }).toList();

    context.read<JobFileUploadCubit>().uploadFiles(
      userId: userId,
      jobId: widget.jobId,
      fileData: fileData,
    );
    return false; // Wait for BlocListener in build()
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobFileUploadCubit, JobFileUploadState>(
      listener: (context, state) {
        if (state is JobFileUploadSuccess) {
          setState(() => _isUploading = false);
          widget.onSuccess();
        } else if (state is JobFileUploadError) {
          showCustomToast('Upload failed: ${state.message}', isError: true);
          setState(() => _isUploading = false);
          // Original logic allowed navigation even if upload fails
          widget.onSuccess();
        }
      },
      child: BlocBuilder<JobBookingCubit, JobBookingState>(
        builder: (context, state) {
          if (state is! JobBookingData) {
            return const Center(child: CircularProgressIndicator());
          }
          final uploadedFiles = state.localFiles;

          return Stack(
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
                            stepNumber: 11,
                            title: 'File Upload',
                            subTitle: '(Optional - Images or Docs)',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 8.h,
                          ),
                          child: Text(
                            'You can upload files now or later (.doc, .xls, .jpg, .png, .mp4)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildUploadOption(
                              icon: Icons.camera_alt_outlined,
                              label: 'Camera',
                              onTap: _handleCameraUpload,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildUploadOption(
                              icon: Icons.folder_outlined,
                              label: 'Gallery',
                              onTap: _handleGalleryUpload,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'Uploaded Files (${uploadedFiles?.length ?? 0})',
                        style: AppTypography.fontSize16,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(24.w),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate((ctx, index) {
                        final file = uploadedFiles![index];
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(Icons.insert_drive_file),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeFile(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }, childCount: uploadedFiles?.length ?? 0),
                    ),
                  ),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox(),
                  ),
                ],
              ),
              if (_isUploading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp, color: Colors.grey[600]),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
