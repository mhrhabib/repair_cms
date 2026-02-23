import 'package:flutter/material.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart'
    as job_booking;
import 'package:repair_cms/features/jobBooking/screens/job_device_label_screen.dart';
import 'package:repair_cms/features/jobBooking/screens/job_thermal_receipt_preview_screen.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/myJobs/screens/receipt_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class JobProgressReceiptsScreen extends StatefulWidget {
  final SingleJobModel job;

  const JobProgressReceiptsScreen({super.key, required this.job});

  @override
  State<JobProgressReceiptsScreen> createState() =>
      _JobProgressReceiptsScreenState();
}

class _JobProgressReceiptsScreenState extends State<JobProgressReceiptsScreen> {
  void _navigateToDeviceLabel(SingleJobModel job) {
    debugPrint('🏷️ Navigating to device label screen');

    // Convert SingleJobModel to CreateJobResponse format
    final jobResponse = _convertToJobResponse(job);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDeviceLabelScreen(
          jobResponse: jobResponse,
          printOption: 'Device Label',
          jobNo: job.data?.jobNo,
        ),
      ),
    );
  }

  void _navigateToThermalReceipt(SingleJobModel job) {
    debugPrint('🖨️ Navigating to thermal receipt screen');

    // Convert SingleJobModel to CreateJobResponse format
    final jobResponse = _convertToJobResponse(job);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobThermalReceiptPreviewScreen(
          jobResponse: jobResponse,
          printOption: 'Thermal Receipt',
        ),
      ),
    );
  }

  job_booking.CreateJobResponse _convertToJobResponse(SingleJobModel job) {
    return job_booking.CreateJobResponse(
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
        jobNo: job.data?.jobNo,
        jobTrackingNumber: job.data?.jobTrackingNumber,
        salutationHTMLmarkup: job.data?.salutationHTMLmarkup,
        termsAndConditionsHTMLmarkup: job.data?.termsAndConditionsHTMLmarkup,
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
                    ?.map(
                      (c) => job_booking.ConditionItem(
                        value: c.value ?? '',
                        id: c.id ?? '',
                      ),
                    )
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
                    ?.map(
                      (item) => job_booking.DefectItem(
                        value: item.value ?? '',
                        id: item.id ?? '',
                      ),
                    )
                    .toList(),
                description: d.description,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        receiptFooter: job.data?.receiptFooter != null
            ? job_booking.ReceiptFooter(
                companyLogo: job.data!.receiptFooter!.companyLogo ?? '',
                companyLogoURL: job.data!.receiptFooter!.companyLogoURL ?? '',
                address: job_booking.CompanyAddress(
                  companyName:
                      job.data!.receiptFooter!.address?.companyName ?? '',
                  street: job.data!.receiptFooter!.address?.street ?? '',
                  num: job.data!.receiptFooter!.address?.num ?? '',
                  zip: job.data!.receiptFooter!.address?.zip ?? '',
                  city: job.data!.receiptFooter!.address?.city ?? '',
                  country: job.data!.receiptFooter!.address?.country ?? '',
                ),
                contact: job_booking.CompanyContact(
                  ceo: job.data!.receiptFooter!.contact?.ceo ?? '',
                  telephone: job.data!.receiptFooter!.contact?.telephone ?? '',
                  email: job.data!.receiptFooter!.contact?.email ?? '',
                  website: job.data!.receiptFooter!.contact?.website ?? '',
                ),
                bank: job_booking.BankDetails(
                  bankName: job.data!.receiptFooter!.bank?.bankName ?? '',
                  iban: job.data!.receiptFooter!.bank?.iban ?? '',
                  bic: job.data!.receiptFooter!.bank?.bic ?? '',
                ),
              )
            : null,
        customerDetails: job.data?.customerDetails != null
            ? job_booking.CustomerDetails(
                customerId: job.data!.customerDetails!.customerId ?? '',
                type: job.data!.customerDetails!.type ?? 'Personal',
                type2: job.data!.customerDetails!.type2 ?? 'personal',
                organization: job.data!.customerDetails!.organization ?? '',
                customerNo: job.data!.customerDetails!.customerNo ?? '',
                email: job.data!.customerDetails!.email ?? '',
                telephone: job.data!.customerDetails!.telephone ?? '',
                telephonePrefix:
                    job.data!.customerDetails!.telephonePrefix ?? '',
                salutation: job.data!.customerDetails!.salutation ?? '',
                firstName: job.data!.customerDetails!.firstName ?? '',
                lastName: job.data!.customerDetails!.lastName ?? '',
                position: job.data!.customerDetails!.position ?? '',
                vatNo: job.data!.customerDetails!.vatNo ?? '',
                reverseCharge:
                    job.data!.customerDetails!.reverseCharge ?? false,
                shippingAddress:
                    job.data!.customerDetails!.shippingAddress != null
                    ? job_booking.CustomerAddress(
                        street:
                            job
                                .data!
                                .customerDetails!
                                .shippingAddress!
                                .street ??
                            '',
                        no:
                            job.data!.customerDetails!.shippingAddress!.zip ??
                            '',
                        zip:
                            job.data!.customerDetails!.shippingAddress!.zip ??
                            '',
                        city:
                            job.data!.customerDetails!.shippingAddress!.city ??
                            '',
                        state: '',
                        country:
                            job
                                .data!
                                .customerDetails!
                                .shippingAddress!
                                .country ??
                            '',
                      )
                    : job_booking.CustomerAddress(
                        street: '',
                        no: '',
                        zip: '',
                        city: '',
                        state: '',
                        country: '',
                      ),
                billingAddress:
                    job.data!.customerDetails!.billingAddress != null
                    ? job_booking.CustomerAddress(
                        street:
                            job.data!.customerDetails!.billingAddress!.street ??
                            '',
                        no:
                            job.data!.customerDetails!.billingAddress!.zip ??
                            '',
                        zip:
                            job.data!.customerDetails!.billingAddress!.zip ??
                            '',
                        city:
                            job.data!.customerDetails!.billingAddress!.city ??
                            '',
                        state:
                            job.data!.customerDetails!.billingAddress!.state ??
                            '',
                        country:
                            job
                                .data!
                                .customerDetails!
                                .billingAddress!
                                .country ??
                            '',
                      )
                    : job_booking.CustomerAddress(
                        street: '',
                        no: '',
                        zip: '',
                        city: '',
                        state: '',
                        country: '',
                      ),
              )
            : null,
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Print',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
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
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: InkWell(
                  onTap: () => _navigateToDeviceLabel(widget.job),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF007AFF,
                            ).withValues(alpha: 0.1),

                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            SolarIconsOutline.tagHorizontal,
                            color: const Color(0xFF007AFF),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Job Label',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade400,
                          size: 16,
                        ),
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
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
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
                          MaterialPageRoute(
                            builder: (context) =>
                                ReceiptScreen(job: widget.job),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildPrintOption(
                      context: context,
                      icon: SolarIconsOutline.printerMinimalistic,
                      title: 'Thermal Receipt',
                      isEnabled: true,
                      onTap: () => _navigateToThermalReceipt(widget.job),
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
                color: isEnabled
                    ? const Color(0xFF007AFF).withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isEnabled ? const Color(0xFF007AFF) : Colors.grey,
                size: 18,
              ),
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
            Icon(
              Icons.arrow_forward_ios,
              color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
              size: 16,
            ),
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
