import 'package:flutter/material.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart' as job_booking;
import 'package:repair_cms/features/jobBooking/screens/job_device_label_screen.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/myJobs/screens/receipt_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class JobProgressReceiptsScreen extends StatefulWidget {
  final SingleJobModel job;

  const JobProgressReceiptsScreen({super.key, required this.job});

  @override
  State<JobProgressReceiptsScreen> createState() => _JobProgressReceiptsScreenState();
}

class _JobProgressReceiptsScreenState extends State<JobProgressReceiptsScreen> {
  void _navigateToDeviceLabel(SingleJobModel job) {
    debugPrint('🏷️ Navigating to device label screen');

    // Convert SingleJobModel to CreateJobResponse format
    final jobResponse = job_booking.CreateJobResponse(
      success: job.success ?? true,
      data: job_booking.JobData(
        sId: job.data?.sId,
        jobType: job.data?.jobType,
        model: job.data?.model,
        deviceId: job.data?.deviceId,
        jobContactId: job.data?.jobContactId,
        defectId: job.data?.defectId,
        physicalLocation: job.data?.physicalLocation,
        emailConfirmation: job.data?.emailConfirmation,
        signatureFilePath: job.data?.signatureFilePath,
        printOption: job.data?.printOption,
        printDeviceLabel: job.data?.printDeviceLabel,
        jobStatus: job.data?.jobStatus
            ?.map(
              (js) => job_booking.JobStatus(
                title: js.title ?? '',
                userId: js.userId ?? '',
                colorCode: js.colorCode ?? '',
                userName: js.userName ?? '',
                createAtStatus: js.createAtStatus ?? 0,
                notifications: js.notifications ?? false,
                notes: js.notes ?? '',
              ),
            )
            .toList(),
        userId: job.data?.userId,
        createdAt: job.data?.createdAt,
        updatedAt: job.data?.updatedAt,
        assignedItems: job.data?.assignedItems
            ?.map((item) {
              if (item is Map) {
                return job_booking.AssignedItemData(
                  productName: item['productName'] ?? item['name'],
                  salePriceIncVat: item['price_incl_vat']?.toDouble() ?? 0.0,
                );
              }
              return null;
            })
            .whereType<job_booking.AssignedItemData>()
            .toList(),
        device: job.data?.device
            ?.map(
              (d) => job_booking.DeviceData(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                imei: d.serialNo,
                condition: d.condition
                    ?.map((c) => job_booking.ConditionItem(value: c.value ?? '', id: c.id ?? ''))
                    .toList(),
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        contact: job.data?.contact
            ?.map(
              (c) => job_booking.ContactData(
                sId: c.sId,
                type: c.type,
                salutation: c.salutation,
                firstName: c.firstName,
                lastName: c.lastName,
                telephone: c.telephone,
                email: c.email,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              ),
            )
            .toList(),
        defect: job.data?.defect
            ?.map(
              (d) => job_booking.DefectData(
                sId: d.sId,
                defect: d.defect
                    ?.map((item) => job_booking.DefectItem(value: item.value ?? '', id: item.id ?? ''))
                    .toList(),
                description: d.description,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobDeviceLabelScreen(jobResponse: jobResponse, printOption: 'Device Label', jobNo: job.data?.jobNo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Print',
          style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),

                child: InkWell(
                  onTap: () => _navigateToDeviceLabel(widget.job),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.1),

                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(SolarIconsOutline.tagHorizontal, color: const Color(0xFF007AFF), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Job Label',
                            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPrintOption(
                      context: context,
                      icon: SolarIconsOutline.documentText,
                      title: 'Job receipt',
                      isEnabled: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReceiptScreen(job: widget.job)),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPrintOption(
                      context: context,
                      icon: SolarIconsOutline.documentText,
                      title: 'Quote',
                      isEnabled: true,
                      onTap: () => debugPrint('Quote tapped'),
                    ),
                    _buildDivider(),
                    _buildPrintOption(
                      context: context,
                      icon: SolarIconsOutline.documentText,
                      title: 'Invoice',
                      isEnabled: true,
                      onTap: () => debugPrint('Invoice tapped'),
                    ),
                    _buildDivider(),
                    _buildPrintOption(
                      context: context,
                      icon: Icons.description_outlined,
                      title: 'Service Report',
                      isEnabled: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrintOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isEnabled ? const Color(0xFF007AFF).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: isEnabled ? const Color(0xFF007AFF) : Colors.grey, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isEnabled ? Colors.black87 : Colors.grey.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
    );
  }
}
