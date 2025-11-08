import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';

class JobCompleteBottomSheet extends StatefulWidget {
  final Function(String notes, bool sendEmail) onConfirm;
  final bool sendEmailNotification;

  const JobCompleteBottomSheet({super.key, required this.onConfirm, this.sendEmailNotification = true});

  @override
  State<JobCompleteBottomSheet> createState() => _JobCompleteBottomSheetState();
}

class _JobCompleteBottomSheetState extends State<JobCompleteBottomSheet> {
  bool sendEmailNotification = true;
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sendEmailNotification = widget.sendEmailNotification;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top handle indicator
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
              'Set Job Complete',
              style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),

            SizedBox(height: 20.h),

            // Notes field
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                hintText: 'Add any notes about job completion...',
              ),
              maxLines: 3,
            ),

            SizedBox(height: 20.h),

            // Send notification section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Send completion email to customer',
                  style: GoogleFonts.roboto(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Email checkbox button
            GestureDetector(
              onTap: () {
                setState(() {
                  sendEmailNotification = !sendEmailNotification;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: sendEmailNotification ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: sendEmailNotification ? Colors.blue : Colors.grey.shade300, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: sendEmailNotification ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: sendEmailNotification ? Colors.blue : Colors.grey.shade400, width: 2),
                      ),
                      child: sendEmailNotification ? Icon(Icons.check, color: Colors.white, size: 14.sp) : null,
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.email_outlined,
                      color: sendEmailNotification ? Colors.blue : Colors.grey.shade600,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Send Email Notification',
                      style: GoogleFonts.roboto(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: sendEmailNotification ? Colors.blue : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfirm(notesController.text, sendEmailNotification);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm Complete',
                  style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}

// Updated helper function
void showJobCompleteBottomSheet(
  BuildContext context, {
  required Function(String notes, bool sendEmail) onConfirm,
  bool sendEmailNotification = true,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => JobCompleteBottomSheet(onConfirm: onConfirm, sendEmailNotification: sendEmailNotification),
  );
}
