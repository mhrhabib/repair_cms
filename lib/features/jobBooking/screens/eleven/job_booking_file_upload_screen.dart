import 'package:image_picker/image_picker.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'dart:io';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/twelve/job_booking_physical_locaiton_screen.dart';

class JobBookingFileUploadScreen extends StatefulWidget {
  const JobBookingFileUploadScreen({super.key});

  @override
  State<JobBookingFileUploadScreen> createState() => _JobBookingFileUploadScreenState();
}

class _JobBookingFileUploadScreenState extends State<JobBookingFileUploadScreen> {
  List<XFile> uploadedImages = [];
  final ImagePicker _picker = ImagePicker();

  void _saveAndNavigate() {
    // Convert XFile to file paths and save to cubit
    final filePaths = uploadedImages.map((file) => file.path).toList();
    context.read<JobBookingCubit>().updateFileUploads(filePaths);

    // Navigate to next screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => const JobBookingPhysicalLocationScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
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
                      onTap: () => _handleCameraUpload(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadOption(
                      icon: Icons.folder_outlined,
                      label: 'Gallery',
                      onTap: () => _handleGalleryUpload(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Uploaded images grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Files (${uploadedImages.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: uploadedImages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No files uploaded yet',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: uploadedImages.length,
                              itemBuilder: (context, index) {
                                return _buildImagePreview(uploadedImages[index]);
                              },
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Navigation buttons
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.chevron_left, color: Colors.grey, size: 24),
                          ),
                        ),

                        const Spacer(),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: uploadedImages.isNotEmpty ? _saveAndNavigate : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: uploadedImages.isNotEmpty ? Colors.blue : Colors.grey,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
  }

  Widget _buildUploadOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile imageFile) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(imageFile.path), width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          ),
        ),

        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                uploadedImages.remove(imageFile);
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
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
        setState(() {
          uploadedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _handleGalleryUpload() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(maxWidth: 1200, maxHeight: 1200, imageQuality: 80);

      if (images.isNotEmpty) {
        setState(() {
          uploadedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting images: $e'), backgroundColor: Colors.red));
    }
  }
}
