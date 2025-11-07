import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    // Load job data only once when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadJobDataIfNeeded();
        _isInitialized = true;
      }
    });
  }

  void _loadJobDataIfNeeded() {
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

      if (photo != null) {
        _addFile(photo.path, photo.name);
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      if (image != null) {
        _addFile(image.path, image.name);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'mp4', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _addFile(result.files.single.path!, result.files.single.name);
      }
    } catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  void _addFile(String path, String name) {
    // TODO: Upload file to server via repository
    _uploadFileToServer(path, name);
  }

  Future<void> _uploadFileToServer(String path, String name) async {
    // Implement your file upload logic here
    // Example:
    // await context.read<JobCubit>().uploadJobFile(widget.jobId, path, name);
    print('Uploading file: $name from $path to job: ${widget.jobId}');

    // Show upload in progress
    _showSuccess('Uploading $name...');
  }

  void _deleteFile(String fileId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // TODO: Implement delete file via repository
              // context.read<JobCubit>().deleteJobFile(widget.jobId, fileId);
              Navigator.pop(context);
              _showSuccess('File deleted successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Files',
          style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFF007AFF), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: _showUploadMethodSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<JobCubit, JobStates>(
        buildWhen: (previous, current) {
          // Only rebuild when necessary states change
          return current is JobLoading || current is JobError || current is JobDetailSuccess;
        },
        builder: (context, state) {
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

          if (state is JobDetailSuccess) {
            final jobData = state.job.data;
            final files = jobData?.files;

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
          }

          // If we have other states or initial state but already initialized, show empty or existing data
          // Check if we have any job data in the cubit that matches our jobId
          final jobCubit = context.read<JobCubit>();
          if (jobCubit.state is JobDetailSuccess) {
            final successState = jobCubit.state as JobDetailSuccess;
            if (successState.job.data?.sId == widget.jobId.data?.sId) {
              final files = successState.job.data?.files;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Expanded(child: files == null || files.isEmpty ? _buildEmptyState() : _buildFilesList(files)),
                ],
              );
            }
          }

          // Fallback: show loading only if we truly need to load data
          return const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)));
        },
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
                colors: [const Color(0xFF007AFF).withOpacity(0.2), const Color(0xFF007AFF).withOpacity(0.1)],
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
    final fileUrl = file.file;
    final isImage = ['jpg', 'jpeg', 'png'].contains(_getFileExtension(fileName));

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
                  child: isImage && fileUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            fileUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(_getFileIcon(fileName), size: 48, color: const Color(0xFF8E8E93)),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF007AFF),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(child: Icon(_getFileIcon(fileName), size: 48, color: const Color(0xFF8E8E93))),
                ),
                // Delete button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _deleteFile(file.id ?? ''),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
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
