import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/core/services/file_service.dart';

/// Professional Job Receipt Widget matching the React PDF design
class JobReceiptWidgetNew extends StatelessWidget {
  final SingleJobModel jobData;
  final bool isPreview;
  static const String baseUrl = 'https://api.repaircms.com';
  static const String trackingDomain = 'https://tracking.repaircms.com';

  const JobReceiptWidgetNew({
    super.key,
    required this.jobData,
    this.isPreview = false,
  });

  // ─── Price parser (handles String, int, double, null safely) ──────────────
  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ─── Calculate subtotal from services + assignedItems (no double-counting) ─
  double _calculateSubTotal() {
    double total = 0.0;

    // Services are typed objects with priceInclVat
    for (final item in jobData.data?.services ?? []) {
      if (item is Map) {
        total += _parsePrice(
          item['price_incl_vat'] ??
              item['priceInclVat'] ??
              item['salePriceIncVat'] ??
              0,
        );
      } else {
        try {
          total += _parsePrice((item as dynamic).priceInclVat);
        } catch (_) {}
      }
    }

    // AssignedItems are Map-based
    for (final item in jobData.data?.assignedItems ?? []) {
      if (item is Map) {
        total += _parsePrice(
          item['price_incl_vat'] ??
              item['priceInclVat'] ??
              item['salePriceIncVat'] ??
              item['sale_price_inc_vat'] ??
              0,
        );
      } else {
        try {
          total += _parsePrice(
            (item as dynamic).salePriceIncVat ?? (item as dynamic).priceInclVat,
          );
        } catch (_) {}
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final data = jobData.data;
    final customer = data?.customerDetails;
    final deviceData = data?.deviceData;
    final device = data?.device?.isNotEmpty == true ? data!.device![0] : null;
    final defect = data?.defect?.isNotEmpty == true ? data?.defect![0] : null;
    final receiptFooter = data?.receiptFooter;

    // ✅ Keep services and assignedItems SEPARATE — do NOT combine into one list
    final List<dynamic> services = data?.services ?? [];
    final List<dynamic> assignedItems = data?.assignedItems ?? [];
    final bool hasItems = services.isNotEmpty || assignedItems.isNotEmpty;

    final content = Container(
      constraints: isPreview ? null : const BoxConstraints(maxWidth: 365),
      width: isPreview ? 595.0 : null,
      height: isPreview ? 650.0 : null,
      padding: const EdgeInsets.all(20.0),
      color: Colors.white,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 595.0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<CompanyCubit, CompanyState>(
                    builder: (context, companyState) {
                      String? logoUrl =
                          (receiptFooter?.companyLogoURL != null &&
                              receiptFooter!.companyLogoURL!.isNotEmpty)
                          ? receiptFooter.companyLogoURL
                          : null;

                      if (logoUrl == null && companyState is CompanyLoaded) {
                        final companyLogo = companyState.company.companyLogo;
                        if (companyLogo != null && companyLogo.isNotEmpty) {
                          logoUrl = FileService.getImageUrl(
                            companyLogo[0].image,
                          );
                        }
                      }

                      return Align(
                        alignment: Alignment.centerRight,
                        child: logoUrl != null && logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                height: 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderLogo(),
                              )
                            : _buildPlaceholderLogo(),
                      );
                    },
                  ),
                  SizedBox(height: 8.h),

                  // Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BlocBuilder<CompanyCubit, CompanyState>(
                      builder: (context, companyState) {
                        return _buildHeader(
                          receiptFooter,
                          customer,
                          companyState,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Job Info
                  _buildJobInfoSection(),
                  SizedBox(height: 2.h),

                  // Barcode
                  _buildBarcode(),
                  SizedBox(height: 4.h),

                  // Title
                  const Text(
                    'Job Receipt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),

                  // Salutation
                  if (data?.salutationHTMLmarkup != null &&
                      data!.salutationHTMLmarkup!.isNotEmpty)
                    _buildHtmlContent(data.salutationHTMLmarkup!)
                  else
                    _buildDefaultSalutation(),
                  SizedBox(height: 6.h),

                  // Device Details
                  _buildDeviceDetails(deviceData, device, defect),
                  SizedBox(height: 6.h),

                  // ✅ Items section with correct subtotal calculation
                  if (hasItems) _buildItemsSection(services, assignedItems),
                  SizedBox(height: 10.h),

                  // Terms
                  if (data?.termsAndConditionsHTMLmarkup != null &&
                      data!.termsAndConditionsHTMLmarkup!.isNotEmpty)
                    _buildHtmlContent(data.termsAndConditionsHTMLmarkup!)
                  else
                    _buildDefaultTerms(),
                  SizedBox(height: 24.h),

                  // QR + Signature
                  _buildQRAndSignature(),
                  const SizedBox(height: 40),

                  // Footer
                  BlocBuilder<CompanyCubit, CompanyState>(
                    builder: (context, companyState) {
                      return _buildFooter(receiptFooter, companyState);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (isPreview) return content;
    return SingleChildScrollView(child: content);
  }

  Widget _buildHeader(
    ReceiptFooter? footer,
    CustomerDetails? customer,
    CompanyState companyState,
  ) {
    final address = footer?.address;
    String companyInfo = _formatCompanyInfo(address);

    if (companyInfo.isEmpty && companyState is CompanyLoaded) {
      final company = companyState.company;
      final parts = <String>[];
      if (company.companyName.isNotEmpty) parts.add(company.companyName);
      final companyAddress =
          company.companyAddress != null && company.companyAddress!.isNotEmpty
          ? company.companyAddress![0]
          : null;
      if (companyAddress != null) {
        if (companyAddress.street != null) {
          parts.add(
            '${companyAddress.street} ${companyAddress.num ?? ''}'.trim(),
          );
        }
        if (companyAddress.zip != null) {
          parts.add(
            '${companyAddress.zip} ${companyAddress.city ?? ''}'.trim(),
          );
        }
      }
      companyInfo = parts.join(' • ');
    }

    final billing = customer?.billingAddress;
    final zipCity = billing != null
        ? '${billing.zip ?? ''} ${billing.city ?? ''}'.trim()
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              companyInfo,
              style: const TextStyle(fontSize: 8, color: Color(0xFF444444)),
            ),
            if (customer?.organization != null &&
                customer!.organization!.isNotEmpty)
              Text(
                customer.organization!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              )
            else if (customer != null)
              Text(
                _formatCustomerName(customer),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (billing != null) ...[
              if (billing.street != null)
                Text(
                  billing.street!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (billing.state != null)
                Text(billing.state!, style: const TextStyle(fontSize: 10)),
              if (zipCity.isNotEmpty)
                Text(
                  zipCity,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (billing.country != null)
                Text(billing.country!, style: const TextStyle(fontSize: 10)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 100.w,
      height: 60.h,
      color: Colors.grey[200],
      child: const Center(
        child: Text('LOGO', style: TextStyle(fontSize: 24, color: Colors.grey)),
      ),
    );
  }

  Widget _buildJobInfoSection() {
    final data = jobData.data;
    final agent = data?.loggedUserId?.isNotEmpty == true
        ? data!.loggedUserId![0]
        : null;
    final customer = data?.customerDetails;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (data?.createdAt != null || data?.updatedAt != null)
                const Text(
                  'Date:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              if (data?.jobNo != null)
                const Text(
                  'Job No:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              if (customer?.customerNo != null &&
                  customer!.customerNo!.isNotEmpty)
                const Text(
                  'Customer No:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              if (agent?.fullName != null)
                const Text(
                  'Agent:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
            ],
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (data?.createdAt != null || data?.updatedAt != null)
                Text(
                  _formatDate(data!.updatedAt ?? data.createdAt!),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (data?.jobNo != null)
                Text(
                  data!.jobNo!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (customer?.customerNo != null &&
                  customer!.customerNo!.isNotEmpty)
                Text(
                  customer.customerNo!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (agent?.fullName != null)
                Text(
                  agent!.fullName!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode() {
    final jobNo = jobData.data?.jobNo ?? 'N/A';
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: jobNo,
          width: 100.w,
          height: 50.h,
          drawText: true,
          style: const TextStyle(fontSize: 8),
        ),
      ),
    );
  }

  Widget _buildDefaultSalutation() {
    return const Text(
      'Hi there,\nThank you for your trust. We are committed to processing your order as quickly as possible.',
      style: TextStyle(fontSize: 8),
    );
  }

  Widget _buildDeviceDetails(
    DeviceData? deviceData,
    Device? device,
    Defect? defect,
  ) {
    final data = jobData.data;

    // Helper to build a table row
    Widget buildRow(String label, String value, {bool showTopBorder = true}) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 140.w,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              color: const Color(0xFFC4C4C4), // Gray background for label
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                color: const Color(
                  0xFFF1F1F1,
                ), // Light gray background for value
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final deviceDetails = [
      _getDeviceName(deviceData, device),
      if (_getDeviceIMEI(deviceData, device).isNotEmpty)
        'IMEI: ${_getDeviceIMEI(deviceData, device)}',
      _getDeviceCondition(deviceData, device),
    ].where((e) => e.isNotEmpty).join(', ');

    return Column(
      children: [
        buildRow('Device details:', deviceDetails, showTopBorder: false),
        buildRow('Physical location:', data?.physicalLocation ?? 'N/A'),
        buildRow(
          'Job type, reference:',
          [
            data?.jobTypes ?? '',
            defect?.reference ?? '',
          ].where((e) => e.isNotEmpty).join(', '),
        ),
        buildRow('Description:', _buildDefectDescription(defect)),
      ],
    );
  }

  String _getDeviceName(DeviceData? deviceData, Device? device) {
    final brand = deviceData?.brand ?? device?.brand ?? '';
    final model = deviceData?.model ?? device?.model ?? '';
    return '$brand $model'.trim();
  }

  String _getDeviceIMEI(DeviceData? deviceData, Device? device) {
    return deviceData?.imei ?? device?.imei ?? '';
  }

  String _getDeviceCondition(DeviceData? deviceData, Device? device) {
    final condition = deviceData?.condition ?? device?.condition;
    if (condition != null && condition.isNotEmpty) {
      return condition.map((c) => c.value ?? '').join(', ');
    }
    return '';
  }

  String _buildDefectDescription(Defect? defect) {
    if (defect == null) return '';
    final parts = <String>[];
    if (defect.defect?.isNotEmpty == true) {
      parts.add(defect.defect!.map((d) => d.value).join(', '));
    }
    if (defect.description != null && defect.description!.isNotEmpty) {
      parts.add(defect.description!);
    }
    return parts.join(', ');
  }

  // ✅ FIXED: Takes services and assignedItems separately, calculates subtotal correctly
  Widget _buildItemsSection(
    List<dynamic> services,
    List<dynamic> assignedItems,
  ) {
    // ✅ Always recalculate — never trust stale model values
    final double subTotal = _calculateSubTotal();
    final double discount = _parsePrice(jobData.data?.discount);
    final double vat = _parsePrice(jobData.data?.vat);
    final double total = subTotal + vat - discount;

    // Build a unified display list from both sources
    final List<_LineItem> lineItems = [];

    for (final item in services) {
      if (item is Map) {
        lineItems.add(
          _LineItem(
            name: item['name'] ?? item['productName'] ?? 'Service',
            price: _parsePrice(
              item['price_incl_vat'] ?? item['priceInclVat'] ?? 0,
            ),
          ),
        );
      } else {
        try {
          lineItems.add(
            _LineItem(
              name: (item as dynamic).name ?? 'Service',
              price: _parsePrice((item as dynamic).priceInclVat),
            ),
          );
        } catch (_) {}
      }
    }

    for (final item in assignedItems) {
      if (item is Map) {
        lineItems.add(
          _LineItem(
            name: item['productName'] ?? item['name'] ?? 'Item',
            price: _parsePrice(
              item['price_incl_vat'] ??
                  item['priceInclVat'] ??
                  item['salePriceIncVat'] ??
                  item['sale_price_inc_vat'] ??
                  0,
            ),
          ),
        );
      } else {
        try {
          lineItems.add(
            _LineItem(
              name:
                  (item as dynamic).productName ??
                  (item as dynamic).name ??
                  'Item',
              price: _parsePrice(
                (item as dynamic).salePriceIncVat ??
                    (item as dynamic).priceInclVat,
              ),
            ),
          );
        } catch (_) {}
      }
    }

    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF808080), width: 1),
              bottom: BorderSide(color: Color(0xFF808080), width: 1),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Price',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),

        // ✅ Line items (each item appears exactly once)
        ...lineItems.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatCurrency(item.price),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ✅ Financial summary using recalculated values
        Align(
          alignment: Alignment.centerRight,
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth > 400
                  ? constraints.maxWidth * 0.4
                  : 200,
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', subTotal, bold: true),
                  if (vat > 0) ...[
                    const SizedBox(height: 4),
                    _buildTotalRow('VAT', vat),
                  ],
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    _buildTotalRow('Discount', -discount),
                  ],
                  const SizedBox(height: 3),
                  Container(height: 1, color: const Color(0xFF707070)),
                  const SizedBox(height: 3),
                  _buildTotalRow('Total', total, bold: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Takes a double directly instead of a raw string/dynamic
  Widget _buildTotalRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 12 : 10,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: bold ? 12 : 10,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultTerms() {
    return const Text(
      'Terms of service: If the defect is not covered by the manufacturer\'s warranty, I agree to the following...',
      style: TextStyle(fontSize: 8, color: Color(0xFF000000)),
    );
  }

  Widget _buildQRAndSignature() {
    final data = jobData.data;
    final trackingUrl =
        '$trackingDomain/${data?.jobTrackingNumber ?? ''}/order-tracking/${data?.sId ?? ''}?email=${data?.customerDetails?.email ?? ''}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (data?.jobTrackingNumber != null)
          SizedBox(
            width: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Repair Tracking',
                  style: TextStyle(fontSize: 8, color: Color(0xFF2589F6)),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: QrImageView(
                    padding: EdgeInsets.zero,
                    data: trackingUrl,
                    version: QrVersions.auto,
                    size: 75.w,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  data!.jobTrackingNumber!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),

        if (data?.signatureFilePath != null)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text(
                      'I agree to the terms and conditions:',
                      style: TextStyle(fontSize: 10),
                    ),
                    _buildSignatureImage(data!.signatureFilePath!),
                  ],
                ),
                Container(
                  width: 150.w,
                  alignment: Alignment.centerRight,
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF808080))),
                  ),
                  padding: const EdgeInsets.only(top: 5),
                  child: const Text(
                    'Date, Signature Client',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSignatureImage(String signaturePath) {
    if (signaturePath.startsWith('data:image')) {
      try {
        final base64String = signaturePath.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 60,
          width: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        );
      } catch (e) {
        debugPrint('Error decoding base64 signature: $e');
        return const SizedBox.shrink();
      }
    }
    return Image.network(
      '$baseUrl/file-upload/download/new?imagePath=$signaturePath',
      height: 60,
      width: 100,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildFooter(ReceiptFooter? footer, CompanyState companyState) {
    final company = companyState is CompanyLoaded ? companyState.company : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFooterColumn([
          if (footer?.address?.companyName != null)
            footer!.address!.companyName!
          else if (company != null && company.companyName.isNotEmpty)
            company.companyName,
          if (footer?.address?.street != null)
            '${footer!.address!.street} ${footer.address!.num ?? ''}'.trim()
          else if (company?.companyAddress?.isNotEmpty == true)
            '${company!.companyAddress![0].street ?? ''} ${company.companyAddress![0].num ?? ''}'
                .trim(),
          if (footer?.address?.zip != null)
            '${footer!.address!.zip} ${footer.address!.city ?? ''}'.trim()
          else if (company?.companyAddress?.isNotEmpty == true)
            '${company!.companyAddress![0].zip ?? ''} ${company.companyAddress![0].city ?? ''}'
                .trim(),
          if (footer?.address?.country != null)
            footer!.address!.country!
          else if (company?.companyAddress?.isNotEmpty == true)
            company!.companyAddress![0].country,
        ]),
        SizedBox(width: 8.w),
        _buildFooterColumn([
          if (footer?.contact?.ceo != null)
            'Owner: ${footer!.contact!.ceo}'
          else if (company?.companyTaxDetail?.isNotEmpty == true)
            'Owner: ${company!.companyTaxDetail![0].ceo}',
          if (footer?.contact?.telephone != null)
            'Telephone: ${footer!.contact!.telephone}'
          else if (company?.companyContactDetail?.isNotEmpty == true)
            'Telephone: ${company!.companyContactDetail![0].telephone}',
          if (footer?.contact?.email != null)
            'Email: ${footer!.contact!.email}'
          else if (company?.companyContactDetail?.isNotEmpty == true)
            'Email: ${company!.companyContactDetail![0].email}',
          if (footer?.contact?.website != null)
            'Web: ${footer!.contact!.website}'
          else if (company?.companyContactDetail?.isNotEmpty == true)
            'Web: ${company!.companyContactDetail![0].website}',
        ]),
        SizedBox(width: 8.w),
        _buildFooterColumn([
          if (footer?.bank?.bankName != null)
            footer!.bank!.bankName!
          else if (company?.companyBankDetail?.isNotEmpty == true)
            company!.companyBankDetail![0].bankName,
          if (footer?.bank?.iban != null)
            'IBAN: ${footer!.bank!.iban}'
          else if (company?.companyBankDetail?.isNotEmpty == true)
            'IBAN: ${company!.companyBankDetail![0].iban}',
          if (footer?.bank?.bic != null)
            'BIC: ${footer!.bank!.bic}'
          else if (company?.companyBankDetail?.isNotEmpty == true)
            'BIC: ${company!.companyBankDetail![0].bic}',
        ]),
      ],
    );
  }

  Widget _buildFooterColumn(List<String?> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .whereType<String>()
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHtmlContent(String htmlContent) {
    String cleanedContent = htmlContent
        .replaceAll(RegExp(r'\{salutation\},?\s*'), '')
        .replaceAll(RegExp(r'\{contact_firstname\}\s*'), '')
        .replaceAll(RegExp(r'\{companyname\}\s*'), '');

    return Html(
      data: cleanedContent,
      style: {
        "body": Style(
          fontSize: FontSize(8),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        "p": Style(fontSize: FontSize(8), margin: Margins.zero),
        "h1": Style(fontSize: FontSize(24), fontWeight: FontWeight.bold),
        "h2": Style(fontSize: FontSize(20), fontWeight: FontWeight.bold),
        "h3": Style(fontSize: FontSize(18), fontWeight: FontWeight.bold),
        "h4": Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
        "h5": Style(fontSize: FontSize(14), fontWeight: FontWeight.bold),
        "h6": Style(fontSize: FontSize(12), fontWeight: FontWeight.bold),
        "strong": Style(fontWeight: FontWeight.bold),
        "b": Style(fontWeight: FontWeight.bold),
        "em": Style(fontStyle: FontStyle.italic),
        "i": Style(fontStyle: FontStyle.italic),
        "u": Style(textDecoration: TextDecoration.underline),
        "a": Style(
          color: Colors.blue,
          textDecoration: TextDecoration.underline,
        ),
        "li": Style(fontSize: FontSize(8)),
        "ul": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        "ol": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
      },
    );
  }

  String _formatCompanyInfo(Address? address) {
    if (address == null) return '';
    final parts = <String>[];
    if (address.companyName != null) parts.add(address.companyName!);
    if (address.street != null) {
      parts.add('${address.street} ${address.num ?? ''}'.trim());
    }
    if (address.zip != null) {
      parts.add('${address.zip} ${address.city ?? ''}'.trim());
    }
    if (address.country != null) {
      parts.add(address.country ?? '');
    }
    return parts.join(' - ');
  }

  String _formatCustomerName(CustomerDetails customer) {
    final parts = <String>[];
    if (customer.salutation != null) parts.add(customer.salutation!);
    if (customer.firstName != null) parts.add(customer.firstName!);
    if (customer.lastName != null) parts.add(customer.lastName!);
    return parts.join('');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '£0.00';
    try {
      final numericAmount = amount is num
          ? amount.toDouble()
          : double.tryParse(amount.toString()) ?? 0.0;
      return '£${numericAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '£0.00';
    }
  }
}

// ─── Internal helper model for line items ─────────────────────────────────────
class _LineItem {
  final String name;
  final double price;
  const _LineItem({required this.name, required this.price});
}
