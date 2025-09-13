import 'package:flutter/material.dart';

class JobBookingFileUploadScreen extends StatefulWidget {
  const JobBookingFileUploadScreen({super.key});

  @override
  State<JobBookingFileUploadScreen> createState() => _JobBookingFileUploadScreenState();
}

class _JobBookingFileUploadScreenState extends State<JobBookingFileUploadScreen> {
  List<String> uploadedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              height: 4,
              width: double.infinity,
              color: Colors.grey[300],
              child: Container(height: 4, width: double.infinity, color: Colors.blue),
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
                      label: 'Phone',
                      onTap: () => _handlePhoneUpload(),
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
                  children: [
                    // Sample uploaded images
                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePreview(
                            'assets/phone_back.jpg', // This would be actual image path
                            hasRedDot: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildImagePreview(
                            'assets/phone_camera.jpg', // This would be actual image path
                            hasRedDot: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Additional upload slots
                    Row(
                      children: [
                        Expanded(child: _buildEmptyUploadSlot()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildEmptyUploadSlot()),
                      ],
                    ),

                    const Spacer(),

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

                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle form submission with uploaded files
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'OK',
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

  Widget _buildImagePreview(String imagePath, {bool hasRedDot = false}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Stack(
        children: [
          // Placeholder for actual image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Icon(Icons.phone_iphone, size: 40, color: Colors.white)),
          ),

          // Red indicator dot
          if (hasRedDot)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                // Handle image deletion
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUploadSlot() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Center(child: Icon(Icons.add, size: 32, color: Colors.grey[400])),
    );
  }

  void _handleCameraUpload() {
    // Implement camera functionality
    // This would typically use image_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera upload would be implemented here'), backgroundColor: Colors.blue),
    );
  }

  void _handlePhoneUpload() {
    // Implement gallery/file picker functionality
    // This would typically use file_picker or image_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone gallery upload would be implemented here'), backgroundColor: Colors.blue),
    );
  }
}
