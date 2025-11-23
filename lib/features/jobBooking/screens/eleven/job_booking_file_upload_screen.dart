import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/jobBooking/cubits/fileUpload/job_file_upload_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/twelve/job_booking_physical_locaiton_screen.dart';

class JobBookingFileUploadScreen extends StatefulWidget {
  final String? jobId;
  const JobBookingFileUploadScreen({super.key, this.jobId});

  @override
  State<JobBookingFileUploadScreen> createState() => _JobBookingFileUploadScreenState();
}

class _JobBookingFileUploadScreenState extends State<JobBookingFileUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<JobFileUploadCubit, JobFileUploadState>(
          listener: (context, state) {
            if (state is JobFileUploadSuccess) {
              debugPrint('✅ Files uploaded successfully to server');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Files uploaded successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              // Navigate to next screen after successful upload
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JobBookingPhysicalLocationScreen(jobId: widget.jobId!)),
              );
            } else if (state is JobFileUploadError) {
              debugPrint('❌ File upload failed: ${state.message}');
              _showErrorSnackBar('Upload failed: ${state.message}');
              // Still allow navigation even if upload fails
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Continue without uploading files?'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Continue',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JobBookingPhysicalLocationScreen(jobId: widget.jobId!)),
                      );
                    },
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: BlocConsumer<JobBookingCubit, JobBookingState>(
        listener: (context, state) {
          if (state is JobBookingData) {
            if (state.isUploading != _isUploading) {
              setState(() {
                _isUploading = state.isUploading;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is! JobBookingData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final uploadedFiles = state.localFiles;
          final isUploading = state.isUploading;

          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: SafeArea(
              child: Column(
                children: [
                  // Progress bar
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 12.h,
                      width: MediaQuery.of(context).size.width * .071 * 11,
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

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: const Center(
                      child: Text(
                        '11',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title and subtitle
                  const Text(
                    'File Upload',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),

                  const SizedBox(height: 8),

                  Text('(.doc, .xls, .jpg, .png, .mp4)', style: TextStyle(fontSize: 14, color: Colors.grey[600])),

                  const SizedBox(height: 32),

                  // Upload options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.camera_alt_outlined,
                            label: 'Camera',
                            onTap: _handleCameraUpload,
                            disabled: isUploading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.folder_outlined,
                            label: 'Gallery',
                            onTap: _handleGalleryUpload,
                            disabled: isUploading,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Uploaded files grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Uploaded Files (${uploadedFiles!.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              if (isUploading) ...[
                                const SizedBox(width: 8),
                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              ],
                              const Spacer(),
                              if (uploadedFiles.isNotEmpty)
                                TextButton(
                                  onPressed: isUploading ? null : _clearAllFiles,
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(color: isUploading ? Colors.grey : Colors.red, fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: uploadedFiles.isEmpty
                                ? _buildEmptyState()
                                : GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: uploadedFiles.length,
                                    itemBuilder: (context, index) {
                                      return _buildFilePreview(uploadedFiles[index], index);
                                    },
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Navigation buttons
                          Row(
                            children: [
                              GestureDetector(
                                onTap: isUploading ? null : () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isUploading ? Colors.grey[100] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.chevron_left,
                                    color: isUploading ? Colors.grey[400] : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: (uploadedFiles.isNotEmpty && !isUploading) ? _saveAndNavigate : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (uploadedFiles.isNotEmpty && !isUploading)
                                        ? Colors.blue
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    elevation: 0,
                                  ),
                                  child: isUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: disabled ? Colors.grey[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: disabled ? Colors.grey[300]! : Colors.grey[400]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: disabled ? Colors.grey[400] : Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: disabled ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No files uploaded yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFilePreview(File localFile, int index) {
    final filePath = localFile.path;
    final fileName = filePath.split('/').last;
    final isImage =
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif');

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.file(
                    localFile,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFileIcon(fileName),
                  )
                : _buildFileIcon(fileName),
          ),
        ),

        // File name overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
            ),
            child: Text(
              fileName.length > 20 ? '${fileName.substring(0, 17)}...' : fileName,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _isUploading ? null : () => _removeFile(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.close, color: _isUploading ? Colors.grey[400] : Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileIcon(String fileName) {
    IconData icon;
    Color color;

    if (fileName.toLowerCase().endsWith('.pdf')) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (fileName.toLowerCase().endsWith('.doc') || fileName.toLowerCase().endsWith('.docx')) {
      icon = Icons.description;
      color = Colors.blue;
    } else if (fileName.toLowerCase().endsWith('.xls') || fileName.toLowerCase().endsWith('.xlsx')) {
      icon = Icons.table_chart;
      color = Colors.green;
    } else if (fileName.toLowerCase().endsWith('.mp4') || fileName.toLowerCase().endsWith('.mov')) {
      icon = Icons.videocam;
      color = Colors.purple;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                fileName.length > 15 ? '${fileName.substring(0, 12)}...' : fileName,
                style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraUpload() async {
    if (_isUploading) return;

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
      _showErrorSnackBar('Error capturing image: $e');
    }
  }

  Future<void> _handleGalleryUpload() async {
    if (_isUploading) return;

    try {
      final List<XFile> images = await _picker.pickMultiImage(maxWidth: 1200, maxHeight: 1200, imageQuality: 80);

      if (images.isNotEmpty) {
        for (final image in images) {
          await context.read<JobBookingCubit>().processAndAddFile(image.path);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting images: $e');
    }
  }

  void _removeFile(int index) {
    if (_isUploading) return;
    context.read<JobBookingCubit>().removeFile(index);
  }

  void _clearAllFiles() {
    if (_isUploading) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Files'),
        content: const Text('Are you sure you want to remove all uploaded files?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JobBookingCubit>().clearFiles();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveAndNavigate() {
    if (_isUploading) return;

    final state = context.read<JobBookingCubit>().state;

    if (state is JobBookingData) {
      // Check if job has been created and we have jobId (from widget parameter or state)
      final jobId = widget.jobId ?? state.jobId;

      if (jobId == null || jobId.isEmpty) {
        debugPrint('⚠️ [FileUploadScreen] No jobId found - job must be created first');
        // Just navigate to next screen without uploading
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobBookingPhysicalLocationScreen(jobId: widget.jobId!)),
        );
        return;
      }

      // Upload files to server if there are any
      if (state.job.files != null && state.job.files!.isNotEmpty) {
        final userId = storage.read('userId') ?? '';

        // Add random IDs to each file before uploading
        final fileData = state.job.files!.map((f) {
          final fileJson = f.toJson();
          // Generate random ID if not already present
          if (fileJson['id'] == null || fileJson['id'].toString().isEmpty) {
            fileJson['id'] = _generateRandomId();
          }
          return fileJson;
        }).toList();

        debugPrint('📤 [FileUploadScreen] Uploading ${state.job.files!.length} files to server');
        debugPrint('🆔 [FileUploadScreen] Job ID: $jobId');
        debugPrint('👤 [FileUploadScreen] User ID: $userId');
        debugPrint('📋 [FileUploadScreen] File data with IDs: $fileData');

        // Upload files using JobFileUploadCubit
        context.read<JobFileUploadCubit>().uploadFiles(userId: userId, jobId: jobId, fileData: fileData);

        // Listen for upload result in the MultiBlocListener above
        // Success: will navigate via listener
        // Error: will show error via listener
      } else {
        debugPrint('ℹ️ [FileUploadScreen] No files to upload');
        // No files, just navigate
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobBookingPhysicalLocationScreen(jobId: widget.jobId!)),
        );
      }
    }
  }

  /// Generate a random ID for file uploads
  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
  }
}
