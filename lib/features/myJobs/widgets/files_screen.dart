import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'dart:io' as io;
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

class FilesScreen extends StatefulWidget {
  final SingleJobModel jobId;

  const FilesScreen({super.key, required this.jobId});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isInitialized = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // Load job data only once when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadJobDataIfNeeded();
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _loadJobDataIfNeeded() {
    if (!_isMounted) return;

    final jobCubit = context.read<JobCubit>();
    final state = jobCubit.state;

    // Only load data if we don't already have the specific job details
    if (state is! JobDetailSuccess || state.job.data?.sId != widget.jobId.data?.sId) {
      jobCubit.getJobById(widget.jobId.data?.sId ?? '');
    }
  }

  void _showUploadMethodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select upload method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),
                _buildUploadOption(
                  icon: Icons.image_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
                _buildUploadOption(
                  icon: Icons.folder_outlined,
                  label: 'Document',
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 32, color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);

      if (photo != null && _isMounted) {
        await _uploadFileToServer(photo.path, photo.name);
      }
    } catch (e) {
      if (_isMounted) {
        _showError('Failed to capture image: $e');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      if (image != null && _isMounted) {
        await _uploadFileToServer(image.path, image.name);
      }
    } catch (e) {
      if (_isMounted) {
        _showError('Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'mp4', 'pdf'],
      );

      if (result != null && result.files.single.path != null && _isMounted) {
        await _uploadFileToServer(result.files.single.path!, result.files.single.name);
      }
    } catch (e) {
      if (_isMounted) {
        _showError('Failed to pick document: $e');
      }
    }
  }

  Future<void> _uploadFileToServer(String path, String name) async {
    if (!_isMounted) return;

    final file = io.File(path);
    final fileSize = await file.length();

    final jobCubit = context.read<JobCubit>();

    await jobCubit.uploadJobFile(
      jobId: widget.jobId.data?.sId ?? '',
      jobNo: widget.jobId.data!.jobNo!,
      filePath: path,
      fileName: name,
      fileSize: fileSize,
    );
  }

  void _deleteFile(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteFile(filePath);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _performDeleteFile(String filePath) {
    if (!_isMounted) return;

    final jobCubit = context.read<JobCubit>();

    jobCubit.deleteJobFile(jobId: widget.jobId.data?.sId ?? '', filePath: filePath);
  }

  void _showError(String message) {
    if (!_isMounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
  }

  void _showSuccess(String message) {
    if (!_isMounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  IconData _getFileIcon(String fileName) {
    final ext = _getFileExtension(fileName);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'mp4':
        return Icons.video_library;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (!_isMounted) return;

        if (state is JobFileUploadSuccess) {
          showCustomToast('File uploaded successfully', isError: false);
        } else if (state is JobFileDeleteSuccess) {
          showCustomToast('File deleted successfully', isError: false);
        } else if (state is JobActionError) {
          showCustomToast(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.back, color: const Color(0xFF007AFF), size: 28.r),
                Text(
                  'Back',
                  style: TextStyle(color: const Color(0xFF007AFF), fontSize: 17.sp),
                ),
              ],
            ),
          ),
          middle: Text(
            'Files',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showUploadMethodSheet,
            child: Icon(CupertinoIcons.add_circled_solid, color: const Color(0xFF007AFF), size: 28.r),
          ),
        ),
        body: BlocBuilder<JobCubit, JobStates>(
          buildWhen: (previous, current) {
            // Rebuild for file-related states and job details
            return current is JobLoading ||
                current is JobError ||
                current is JobDetailSuccess ||
                current is JobFileUploading ||
                current is JobFileUploadSuccess ||
                current is JobFileDeleteSuccess;
          },
          builder: (context, state) {
            // Show loading for file upload
            if (state is JobFileUploading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF007AFF)),
                    SizedBox(height: 16),
                    Text('Uploading file...', style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93))),
                  ],
                ),
              );
            }

            // Show loading only if we're specifically loading AND we don't have data yet
            if (state is JobLoading && !_isInitialized) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)));
            }

            if (state is JobError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF3B30)),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading files',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<JobCubit>().getJobById(widget.jobId.data?.sId ?? '');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Get files from current state
            List<File>? files;
            if (state is JobDetailSuccess) {
              files = state.job.data?.files;
            } else if (state is JobFileUploadSuccess) {
              files = state.job.data?.files;
            } else if (state is JobFileDeleteSuccess) {
              files = state.job.data?.files;
            } else {
              // Try to get files from existing job data
              final jobCubit = context.read<JobCubit>();
              if (jobCubit.state is JobDetailSuccess) {
                final successState = jobCubit.state as JobDetailSuccess;
                if (successState.job.data?.sId == widget.jobId.data?.sId) {
                  files = successState.job.data?.files;
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Upload Info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Upload',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Supported files: .doc, xls, jpg, png, mp4',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                      ),
                    ],
                  ),
                ),

                // Files List or Empty State
                Expanded(child: files == null || files.isEmpty ? _buildEmptyState() : _buildFilesList(files)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF007AFF).withValues(alpha: 0.2),
                  const Color(0xFF007AFF).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.cloud_outlined, size: 64, color: Color(0xFF007AFF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Files',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have no\nfiles uploaded yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList(List<File> files) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<JobCubit>().getJobById(widget.jobId.data?.sId ?? '');
      },
      color: const Color(0xFF007AFF),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return _buildFileCard(file);
        },
      ),
    );
  }

  Widget _buildFileCard(File file) {
    final fileName = file.fileName ?? 'Unknown';
    final fileSize = file.size ?? 0;
    final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(_getFileExtension(fileName));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Preview/Icon
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: isImage && file.imageUrl != null && file.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            file.imageUrl!, // Using the imageUrl getter which constructs the full URL
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('🖼️ Error loading image from: ${file.imageUrl}');
                              debugPrint('❌ Error: $error');
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_getFileIcon(fileName), size: 48, color: const Color(0xFF8E8E93)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Image not found',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF8E8E93)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                debugPrint('✅ Image loaded successfully from: ${file.imageUrl}');
                                return child;
                              }
                              final progress = loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(value: progress, color: const Color(0xFF007AFF)),
                                    if (progress != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93)),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getFileIcon(fileName), size: 48, color: const Color(0xFF8E8E93)),
                              const SizedBox(height: 4),
                              Text(
                                _getFileExtension(fileName).toUpperCase(),
                                style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93)),
                              ),
                            ],
                          ),
                        ),
                ),
                // Delete button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _deleteFile(file.file ?? ''),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFFF3B30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // File Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 4),
                Text(_formatFileSize(fileSize), style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
