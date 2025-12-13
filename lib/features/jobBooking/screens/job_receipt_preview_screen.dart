import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/routes/route_names.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/create_job_request.dart' as job_booking;
import 'package:repair_cms/features/myJobs/models/single_job_model.dart' as my_jobs;
import 'package:repair_cms/features/myJobs/widgets/job_receipt_widget_new.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/models/printer_config_model.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';

class JobReceiptPreviewScreen extends StatefulWidget {
  final job_booking.CreateJobResponse jobResponse;
  final String printOption; // 'A4 Receipt', 'Thermal Receipt', 'Device Label'

  const JobReceiptPreviewScreen({super.key, required this.jobResponse, required this.printOption});

  @override
  State<JobReceiptPreviewScreen> createState() => _JobReceiptPreviewScreenState();
}

class _JobReceiptPreviewScreenState extends State<JobReceiptPreviewScreen> {
  final _settingsService = PrinterSettingsService();
  my_jobs.SingleJobModel? _completeJobData;
  bool _isLoadingCompleteData = false;

  @override
  void initState() {
    super.initState();
    _fetchCompleteJobData();
  }

  /// Fetch complete job data including tracking number
  Future<void> _fetchCompleteJobData() async {
    final jobId = widget.jobResponse.data?.sId;
    if (jobId == null || jobId.isEmpty) {
      debugPrint('⚠️ [ReceiptPreview] No job ID available, skipping complete data fetch');
      return;
    }

    setState(() => _isLoadingCompleteData = true);

    debugPrint('🔄 [ReceiptPreview] Fetching complete job data for ID: $jobId');
    context.read<JobCubit>().getJobById(jobId);
  }

  /// Show printer selection dialog
  Future<void> _showPrinterSelection() async {
    debugPrint('🖨️ Opening printer selection dialog');

    final allPrinters = _settingsService.getAllPrinters();
    final List<PrinterConfigModel> configuredPrinters = [
      ...allPrinters['thermal'] ?? [],
      ...allPrinters['label'] ?? [],
      ...allPrinters['a4'] ?? [],
    ];

    debugPrint('📊 Found ${configuredPrinters.length} configured printers');

    if (configuredPrinters.isEmpty) {
      // No printers configured - show discovery option
      final shouldDiscover = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Printers Configured'),
          content: const Text(
            'No printers are configured yet. Would you like to search for available printers on your network?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Search for Printers')),
          ],
        ),
      );

      if (shouldDiscover == true && mounted) {
        _discoverPrinters();
      }
      return;
    }

    // Get default printer based on selected print option
    String? defaultPrinterType;
    if (widget.printOption == 'Thermal Receipt') {
      defaultPrinterType = 'thermal';
    } else if (widget.printOption == 'Device Label') {
      defaultPrinterType = 'label';
    } else {
      defaultPrinterType = 'a4';
    }

    final selectedPrinter = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (context) =>
          _PrinterSelectionDialog(printers: configuredPrinters, defaultPrinterType: defaultPrinterType),
    );

    if (selectedPrinter != null && mounted) {
      debugPrint('🎯 User selected: ${selectedPrinter.printerBrand} ${selectedPrinter.printerType} printer');
      _printReceipt(selectedPrinter);
    }
  }

  /// Discover printers on the network
  Future<void> _discoverPrinters() async {
    debugPrint('🔍 Starting printer discovery...');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Searching for printers...'),
                SizedBox(height: 8),
                Text('This may take a few moments', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Scan network for printers
      final discoveredPrinters = await _scanForNetworkPrinters();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (discoveredPrinters.isEmpty) {
        if (mounted) {
          showCustomToast(
            'No printers found on the network. Please ensure your printer is connected and try again.',
            isError: true,
          );
        }
        return;
      }

      // Show discovered printers
      if (mounted) {
        final selectedPrinter = await showDialog<Map<String, String>>(
          context: context,
          builder: (context) => _DiscoveredPrintersDialog(printers: discoveredPrinters),
        );

        if (selectedPrinter != null && mounted) {
          _configurePrinter(selectedPrinter);
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      debugPrint('❌ Error discovering printers: $e');
      if (mounted) {
        showCustomToast('Failed to discover printers: ${e.toString()}', isError: true);
      }
    }
  }

  /// Scan network for available printers
  Future<List<Map<String, String>>> _scanForNetworkPrinters() async {
    debugPrint('🌐 Scanning network for printers...');

    final List<Map<String, String>> discoveredPrinters = [];

    try {
      // Get device's network info
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();

      if (wifiIP == null) {
        debugPrint('❌ Not connected to WiFi');
        return discoveredPrinters;
      }

      debugPrint('📱 Device IP: $wifiIP');

      // Parse IP to get network prefix (e.g., 192.168.1.x)
      final ipParts = wifiIP.split('.');
      if (ipParts.length != 4) {
        debugPrint('❌ Invalid IP format: $wifiIP');
        return discoveredPrinters;
      }

      final networkPrefix = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';
      debugPrint('🌐 Network prefix: $networkPrefix.x');

      // Common printer ports
      final printerPorts = [9100, 515, 631]; // Raw, LPD, IPP

      // Scan common printer IP addresses (last octet from 1 to 254)
      // For performance, scan in smaller batches
      for (int i = 1; i <= 254; i++) {
        final ip = '$networkPrefix.$i';

        // Skip device's own IP
        if (ip == wifiIP) continue;

        // Try connecting to printer ports (with timeout)
        for (final port in printerPorts) {
          try {
            final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 100));
            socket.destroy();

            debugPrint('✅ Found potential printer at $ip:$port');
            discoveredPrinters.add({'ip': ip, 'port': port.toString(), 'name': 'Printer at $ip'});
            break; // Found on this IP, move to next
          } catch (e) {
            // Connection failed, try next port/IP
            continue;
          }
        }
      }

      debugPrint('📊 Discovery complete: Found ${discoveredPrinters.length} potential printers');
      return discoveredPrinters;
    } catch (e) {
      debugPrint('❌ Network scan error: $e');
      return discoveredPrinters;
    }
  }

  /// Configure selected printer
  Future<void> _configurePrinter(Map<String, String> printerInfo) async {
    debugPrint('⚙️ Configuring printer: ${printerInfo['ip']}');

    // Show configuration dialog
    final config = await showDialog<PrinterConfigModel>(
      context: context,
      builder: (context) => _PrinterConfigurationDialog(printerInfo: printerInfo),
    );

    if (config != null) {
      try {
        await _settingsService.savePrinterConfig(config);
        if (mounted) {
          showCustomToast('Printer configured successfully!', isError: false);

          // Now show printer selection
          _showPrinterSelection();
        }
      } catch (e) {
        debugPrint('❌ Error saving printer config: $e');
        if (mounted) {
          showCustomToast('Failed to save printer configuration', isError: true);
        }
      }
    }
  }

  /// Print receipt with selected printer
  Future<void> _printReceipt(PrinterConfigModel printer) async {
    debugPrint('🚀 Starting print job with ${printer.printerBrand} ${printer.printerType}');

    showCustomToast('Print functionality will be implemented here', isError: false);

    // TODO: Implement actual printing based on printer type
    if (printer.printerType == 'thermal') {
      // Use thermal printer with paper width setting
      debugPrint('🖨️ Thermal printer - Paper width: ${printer.paperWidth ?? 80}mm');
    } else if (printer.printerType == 'label') {
      // Use label printer with label size setting
      debugPrint('🖨️ Label printer - Label size: ${printer.labelSize}');
    } else {
      // Use A4 printer
      debugPrint('🖨️ A4 printer');
    }
  }

  /// Convert CreateJobResponse to SingleJobModel for JobReceiptWidgetNew
  my_jobs.SingleJobModel _convertToSingleJobModel() {
    final data = widget.jobResponse.data;

    debugPrint('📋 [ReceiptPreview] Converting job response to SingleJobModel');
    debugPrint('📋 [ReceiptPreview] Job No: ${data?.jobNo}');
    debugPrint('📋 [ReceiptPreview] Job Tracking Number from response: ${data?.jobTrackingNumber}');
    debugPrint('📋 [ReceiptPreview] Receipt Footer from response: ${data?.receiptFooter != null}');
    debugPrint('📋 [ReceiptPreview] Customer Details from response: ${data?.customerDetails != null}');
    debugPrint('📋 [ReceiptPreview] Salutation HTML Length from response: ${data?.salutationHTMLmarkup?.length ?? 0}');
    debugPrint(
      '📋 [ReceiptPreview] Terms HTML Length from response: ${data?.termsAndConditionsHTMLmarkup?.length ?? 0}',
    );

    // WORKAROUND: API doesn't return receiptFooter/customerDetails/jobTrackingNumber in PATCH response
    // So we get it from JobBookingCubit state instead
    final jobBookingCubit = context.read<JobBookingCubit>();
    final jobBookingState = jobBookingCubit.state;

    job_booking.ReceiptFooter? receiptFooterFromCubit;
    job_booking.CustomerDetails? customerDetailsFromCubit;
    String? salutationFromCubit;
    String? termsFromCubit;

    if (jobBookingState is JobBookingData) {
      receiptFooterFromCubit = jobBookingState.job.receiptFooter;
      customerDetailsFromCubit = jobBookingState.job.customerDetails;
      salutationFromCubit = jobBookingState.job.salutationHTMLmarkup;
      termsFromCubit = jobBookingState.job.termsAndConditionsHTMLmarkup;

      debugPrint('📋 [ReceiptPreview] Using data from JobBookingCubit:');
      debugPrint('   - Receipt Footer: ${receiptFooterFromCubit.companyLogoURL}');
      debugPrint('   - Customer Details: ${customerDetailsFromCubit.firstName} ${customerDetailsFromCubit.lastName}');
      debugPrint('   - Salutation: ${salutationFromCubit.length} chars');
      debugPrint('   - Terms: ${termsFromCubit.length} chars');
    }

    // Use data from response where available, fallback to cubit data
    final finalReceiptFooter = data?.receiptFooter ?? receiptFooterFromCubit;
    final finalCustomerDetails = data?.customerDetails ?? customerDetailsFromCubit;
    final finalSalutation = data?.salutationHTMLmarkup ?? salutationFromCubit;
    final finalTerms = data?.termsAndConditionsHTMLmarkup ?? termsFromCubit;

    // Debug final receipt footer data
    if (finalReceiptFooter != null) {
      debugPrint('📋 [ReceiptPreview] Final Receipt Footer Details:');
      debugPrint('   - Logo URL: ${finalReceiptFooter.companyLogoURL}');
      debugPrint('   - Company Name: ${finalReceiptFooter.address.companyName}');
      debugPrint('   - Street: ${finalReceiptFooter.address.street} ${finalReceiptFooter.address.num}');
      debugPrint('   - City: ${finalReceiptFooter.address.zip} ${finalReceiptFooter.address.city}');
      debugPrint('   - Country: ${finalReceiptFooter.address.country}');
      debugPrint('   - CEO: ${finalReceiptFooter.contact.ceo}');
      debugPrint('   - Telephone: ${finalReceiptFooter.contact.telephone}');
      debugPrint('   - Email: ${finalReceiptFooter.contact.email}');
      debugPrint('   - Website: ${finalReceiptFooter.contact.website}');
      debugPrint('   - Bank: ${finalReceiptFooter.bank.bankName}');
      debugPrint('   - IBAN: ${finalReceiptFooter.bank.iban}');
      debugPrint('   - BIC: ${finalReceiptFooter.bank.bic}');
    } else {
      debugPrint('❌ [ReceiptPreview] Final Receipt Footer is NULL!');
    }

    // Convert assignedItems to dynamic list that widget expects
    final assignedItemsList = data?.assignedItems?.map((item) {
      return {
        'productName': item.productName ?? '',
        'name': item.productName ?? '',
        'price_incl_vat': item.salePriceIncVat ?? 0,
      };
    }).toList();

    // Calculate totals from assigned items
    final calculatedSubTotal =
        data?.assignedItems?.fold<double>(0.0, (sum, item) => sum + (item.salePriceIncVat ?? 0)) ?? 0.0;
    final calculatedDiscount = 0.0;
    final calculatedVat = 0.0; // VAT is already included in salePriceIncVat
    final calculatedTotal = calculatedSubTotal;

    debugPrint('💰 [ReceiptPreview] Calculated Totals:');
    debugPrint('   - Subtotal: $calculatedSubTotal');
    debugPrint('   - Discount: $calculatedDiscount');
    debugPrint('   - VAT: $calculatedVat (included)');
    debugPrint('   - Total: $calculatedTotal');

    return my_jobs.SingleJobModel(
      success: widget.jobResponse.success,
      data: my_jobs.Data(
        sId: data?.sId,
        jobType: data?.jobType,
        jobTypes: data?.jobType,
        model: data?.model,
        deviceId: data?.deviceId,
        jobContactId: data?.jobContactId,
        defectId: data?.defectId,
        physicalLocation: data?.physicalLocation,
        emailConfirmation: data?.emailConfirmation,
        files: data?.files?.map((f) => my_jobs.File(id: f.id, file: f.file, fileName: null, size: null)).toList(),
        signatureFilePath: data?.signatureFilePath,
        printOption: data?.printOption,
        printDeviceLabel: data?.printDeviceLabel,
        jobStatus: data?.jobStatus
            ?.map(
              (js) => my_jobs.JobStatus(
                title: js.title,
                userId: js.userId,
                colorCode: js.colorCode,
                userName: js.userName,
                createAtStatus: js.createAtStatus,
                notifications: js.notifications,
                notes: js.notes,
              ),
            )
            .toList(),
        userId: data?.userId,
        createdAt: data?.createdAt,
        updatedAt: data?.updatedAt,
        services: data?.services,
        assignedItems: assignedItemsList,
        device: data?.device
            ?.map(
              (d) => my_jobs.Device(
                sId: d.sId,
                brand: d.brand,
                model: d.model,
                condition: d.condition?.map((c) => my_jobs.Condition(value: c.value, id: c.id)).toList(),
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        contact: data?.contact
            ?.map(
              (c) => my_jobs.Contact(
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
        defect: data?.defect
            ?.map(
              (d) => my_jobs.Defect(
                sId: d.sId,
                defect: d.defect?.map((item) => my_jobs.DefectItem(value: item.value, id: item.id)).toList(),
                description: d.description,
                createdAt: d.createdAt,
                updatedAt: d.updatedAt,
              ),
            )
            .toList(),
        jobNo: data?.jobNo ?? data?.model ?? data?.sId ?? 'N/A',
        total: calculatedTotal,
        subTotal: calculatedSubTotal,
        vat: calculatedVat,
        discount: calculatedDiscount,
        jobTrackingNumber: _completeJobData?.data?.jobTrackingNumber ?? data?.jobTrackingNumber ?? data?.jobNo,
        receiptFooter: finalReceiptFooter != null
            ? my_jobs.ReceiptFooter(
                companyLogo: finalReceiptFooter.companyLogo,
                // Convert path to full URL for image display
                companyLogoURL:
                    finalReceiptFooter.companyLogoURL.isNotEmpty &&
                        !finalReceiptFooter.companyLogoURL.startsWith('http')
                    ? 'https://api.repaircms.com/file-upload/download/new?imagePath=${finalReceiptFooter.companyLogoURL}'
                    : finalReceiptFooter.companyLogoURL,
                address: my_jobs.Address(
                  companyName: finalReceiptFooter.address.companyName,
                  street: finalReceiptFooter.address.street,
                  num: finalReceiptFooter.address.num,
                  zip: finalReceiptFooter.address.zip,
                  city: finalReceiptFooter.address.city,
                  country: finalReceiptFooter.address.country,
                ),
                contact: my_jobs.ContactInfo(
                  ceo: finalReceiptFooter.contact.ceo,
                  telephone: finalReceiptFooter.contact.telephone,
                  email: finalReceiptFooter.contact.email,
                  website: finalReceiptFooter.contact.website,
                ),
                bank: my_jobs.Bank(
                  bankName: finalReceiptFooter.bank.bankName,
                  iban: finalReceiptFooter.bank.iban,
                  bic: finalReceiptFooter.bank.bic,
                ),
              )
            : null,
        customerDetails: finalCustomerDetails != null
            ? my_jobs.CustomerDetails(
                customerId: finalCustomerDetails.customerId,
                type: finalCustomerDetails.type,
                type2: finalCustomerDetails.type2,
                organization: finalCustomerDetails.organization,
                customerNo: finalCustomerDetails.customerNo,
                email: finalCustomerDetails.email,
                telephone: finalCustomerDetails.telephone,
                telephonePrefix: finalCustomerDetails.telephonePrefix,
                salutation: finalCustomerDetails.salutation,
                firstName: finalCustomerDetails.firstName,
                lastName: finalCustomerDetails.lastName,
                position: finalCustomerDetails.position,
                vatNo: finalCustomerDetails.vatNo,
                reverseCharge: finalCustomerDetails.reverseCharge,
              )
            : null,
        salutationHTMLmarkup: finalSalutation,
        termsAndConditionsHTMLmarkup: finalTerms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobDetailSuccess) {
          debugPrint('✅ [ReceiptPreview] Complete job data loaded with tracking: ${state.job.data?.jobTrackingNumber}');
          setState(() {
            _completeJobData = state.job;
            _isLoadingCompleteData = false;
          });
        } else if (state is JobError) {
          debugPrint('❌ [ReceiptPreview] Error loading complete job data: ${state.message}');
          setState(() => _isLoadingCompleteData = false);
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // ALWAYS use converted data which includes receipt footer from cubit
    // Then overlay the tracking number from complete job data if available
    final jobModel = _convertToSingleJobModel();

    // If we have complete data with tracking number, update it
    if (_completeJobData?.data?.jobTrackingNumber != null) {
      debugPrint(
        '✅ [ReceiptPreview] Merging tracking number from complete data: ${_completeJobData!.data!.jobTrackingNumber}',
      );
      // The jobModel already has everything we need from cubit,
      // we just need to update the tracking number field
      // Since SingleJobModel doesn't have copyWith, we'll let the widget handle it
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
          onPressed: () {
            Navigator.of(context).popUntil(ModalRoute.withName(RouteNames.home));
          },
        ),
        title: Text(
          'Job Receipt',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: AppColors.primary, size: 24.sp),
            onPressed: _showPrinterSelection,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 650.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  children: [
                    JobReceiptWidgetNew(isPreview: true, jobData: jobModel),
                    // Show loading overlay when fetching complete job data
                    if (_isLoadingCompleteData)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.8),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: AppColors.primary),
                                SizedBox(height: 12.h),
                                Text(
                                  'Loading tracking number...',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Printer selection dialog (same as ReceiptScreen)
class _PrinterSelectionDialog extends StatelessWidget {
  final List<PrinterConfigModel> printers;
  final String? defaultPrinterType;

  const _PrinterSelectionDialog({required this.printers, this.defaultPrinterType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Printer'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: printers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final printer = printers[index];
            final isDefault = printer.printerType == defaultPrinterType;

            return ListTile(
              leading: Icon(_getPrinterIcon(printer.printerType), color: Colors.blue, size: 32),
              title: Text(_getPrinterTitle(printer.printerType), style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(printer.printerModel ?? 'Unknown Model'),
                  Text(printer.ipAddress, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).pop(printer),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }

  IconData _getPrinterIcon(String printerType) {
    switch (printerType) {
      case 'thermal':
        return Icons.receipt_long;
      case 'label':
        return Icons.label;
      case 'a4':
        return Icons.description;
      default:
        return Icons.print;
    }
  }

  String _getPrinterTitle(String printerType) {
    switch (printerType) {
      case 'thermal':
        return 'Thermal Printer (80mm)';
      case 'label':
        return 'Label Printer';
      case 'a4':
        return 'A4 Receipt Printer';
      default:
        return 'Printer';
    }
  }
}

/// Dialog to show discovered printers
class _DiscoveredPrintersDialog extends StatelessWidget {
  final List<Map<String, String>> printers;

  const _DiscoveredPrintersDialog({required this.printers});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Discovered Printers'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: printers.length,
          itemBuilder: (context, index) {
            final printer = printers[index];
            return ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: Text(printer['name'] ?? 'Unknown Printer'),
              subtitle: Text('IP: ${printer['ip']}\nPort: ${printer['port']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).pop(printer),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }
}

/// Dialog to configure a discovered printer
class _PrinterConfigurationDialog extends StatefulWidget {
  final Map<String, String> printerInfo;

  const _PrinterConfigurationDialog({required this.printerInfo});

  @override
  State<_PrinterConfigurationDialog> createState() => _PrinterConfigurationDialogState();
}

class _PrinterConfigurationDialogState extends State<_PrinterConfigurationDialog> {
  String _printerType = 'thermal';
  String _printerBrand = 'Brother';
  String? _printerModel;
  int _paperWidth = 80;
  LabelSize? _labelSize;
  bool _isDefault = true;
  List<LabelSize> _availableLabelSizes = [];

  final List<String> _printerBrands = ['Brother', 'Epson', 'Zebra', 'Dymo', 'Other'];
  final List<int> _paperWidths = [58, 80];

  @override
  void initState() {
    super.initState();
    _updateLabelSizes();
  }

  void _updateLabelSizes() {
    switch (_printerBrand) {
      case 'Brother':
        _availableLabelSizes = LabelSize.getBrotherSizes();
        break;
      case 'Dymo':
        _availableLabelSizes = LabelSize.getDymoSizes();
        break;
      default:
        _availableLabelSizes = LabelSize.getXprinterSizes();
    }
    if (_availableLabelSizes.isNotEmpty) {
      _labelSize = _availableLabelSizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure Printer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP Address: ${widget.printerInfo['ip']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Printer Type
            DropdownButtonFormField<String>(
              initialValue: _printerType,
              decoration: const InputDecoration(labelText: 'Printer Type'),
              items: const [
                DropdownMenuItem(value: 'thermal', child: Text('Thermal Receipt')),
                DropdownMenuItem(value: 'label', child: Text('Label Printer')),
                DropdownMenuItem(value: 'a4', child: Text('A4 Printer')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _printerType = value);
                }
              },
            ),
            const SizedBox(height: 12),

            // Printer Brand
            DropdownButtonFormField<String>(
              initialValue: _printerBrand,
              decoration: const InputDecoration(labelText: 'Printer Brand'),
              items: _printerBrands.map((brand) => DropdownMenuItem(value: brand, child: Text(brand))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _printerBrand = value;
                    _updateLabelSizes();
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // Printer Model (optional)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Printer Model (Optional)', hintText: 'e.g., QL-820NWB'),
              onChanged: (value) => _printerModel = value.isEmpty ? null : value,
            ),
            const SizedBox(height: 12),

            // Paper Width (for thermal printers)
            if (_printerType == 'thermal') ...[
              DropdownButtonFormField<int>(
                initialValue: _paperWidth,
                decoration: const InputDecoration(labelText: 'Paper Width'),
                items: _paperWidths.map((width) => DropdownMenuItem(value: width, child: Text('${width}mm'))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paperWidth = value);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],

            // Label Size (for label printers)
            if (_printerType == 'label') ...[
              DropdownButtonFormField<LabelSize>(
                initialValue: _labelSize,
                decoration: const InputDecoration(labelText: 'Label Size'),
                items: _availableLabelSizes
                    .map((size) => DropdownMenuItem(value: size, child: Text(size.toString())))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _labelSize = value);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],

            // Set as Default
            CheckboxListTile(
              value: _isDefault,
              title: const Text('Set as default printer'),
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() => _isDefault = value ?? true);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final config = PrinterConfigModel(
              printerType: _printerType,
              printerBrand: _printerBrand,
              printerModel: _printerModel,
              ipAddress: widget.printerInfo['ip']!,
              protocol: 'TCP',
              port: int.parse(widget.printerInfo['port']!),
              paperWidth: _printerType == 'thermal' ? _paperWidth : null,
              labelSize: _printerType == 'label' ? _labelSize : null,
              isDefault: _isDefault,
            );
            Navigator.of(context).pop(config);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
