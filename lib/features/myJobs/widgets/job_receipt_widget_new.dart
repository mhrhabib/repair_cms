import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_html/flutter_html.dart';

/// Professional Job Receipt Widget matching the React PDF design
class JobReceiptWidgetNew extends StatelessWidget {
  final SingleJobModel jobData;
  final bool isPreview; // when true, render full-size (no internal scrolling) for print preview
  static const String baseUrl = 'https://staging-api.repaircms.com';
  static const String trackingDomain = 'https://tracking.repaircms.com';

  const JobReceiptWidgetNew({super.key, required this.jobData, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    final data = jobData.data;
    final customer = data?.customerDetails;
    final deviceData = data?.deviceData;
    final device = data?.device?.isNotEmpty == true ? data!.device![0] : null;
    final defect = data?.defect?.isNotEmpty == true ? data?.defect![0] : null;
    final receiptFooter = data?.receiptFooter;
    final assignedItems = data?.assignedItems ?? [];

    final content = Container(
      // For print preview render full A4 width; otherwise constrain for small previews
      constraints: isPreview ? null : const BoxConstraints(maxWidth: 365),
      width: isPreview ? 595.0 : null,
      height: isPreview ? 650.0 : null,
      padding: const EdgeInsets.all(20.0), // 2cm padding like PDF
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
                  if (receiptFooter?.companyLogoURL != null && receiptFooter!.companyLogoURL!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Image.network(
                        receiptFooter.companyLogoURL!,
                        // width: 100,//
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderLogo(),
                      ),
                    )
                  else
                    Align(alignment: Alignment.centerRight, child: _buildPlaceholderLogo()),
                  SizedBox(height: 8.h),

                  // Header Section
                  Align(alignment: Alignment.centerLeft, child: _buildHeader(receiptFooter, customer)),
                  SizedBox(height: 16.h),

                  // Job Info and Barcode Section
                  _buildJobInfoSection(),
                  SizedBox(height: 8.h),

                  // Barcode
                  _buildBarcode(),
                  SizedBox(height: 4.h),

                  // Job Receipt Title
                  const Text('Job Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2.h),

                  // Salutation HTML
                  if (data?.salutationHTMLmarkup != null && data!.salutationHTMLmarkup!.isNotEmpty)
                    _buildHtmlContent(data.salutationHTMLmarkup!)
                  else
                    _buildDefaultSalutation(),
                  SizedBox(height: 6.h),

                  // Device Details Section
                  _buildDeviceDetails(deviceData, device, defect),
                  SizedBox(height: 6.h),
                  // Items/Services Section
                  if (assignedItems.isNotEmpty) _buildItemsSection(assignedItems),
                  SizedBox(height: 10.h),

                  // Terms and Conditions HTML
                  if (data?.termsAndConditionsHTMLmarkup != null && data!.termsAndConditionsHTMLmarkup!.isNotEmpty)
                    _buildHtmlContent(data.termsAndConditionsHTMLmarkup!)
                  else
                    _buildDefaultTerms(),
                  SizedBox(height: 24.h),

                  // QR Code and Signature Section
                  _buildQRAndSignature(),
                  const SizedBox(height: 40),

                  // Footer Section
                  _buildFooter(receiptFooter),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (isPreview) {
      // Return the content as-is (no scrolling) so it can be scaled by the preview container
      return content;
    }

    // Default in-app rendering: allow scrolling for long receipts
    return SingleChildScrollView(child: content);
  }

  /// Header with company info and logo
  Widget _buildHeader(ReceiptFooter? footer, CustomerDetails? customer) {
    final address = footer?.address;
    final companyInfo = _formatCompanyInfo(address);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Customer Details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company info line (small gray text)
            Text(companyInfo, style: const TextStyle(fontSize: 8, color: Color(0xFF444444))),
            SizedBox(height: 6.h),
            // Customer organization or name
            if (customer?.organization != null && customer!.organization!.isNotEmpty)
              Text(customer.organization!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400))
            else if (customer != null)
              Text(_formatCustomerName(customer), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
            // Customer address
            if (customer?.billingAddress != null) ...[
              const SizedBox(height: 2),
              if (customer!.billingAddress!.street != null)
                Text(
                  customer.billingAddress!.street!,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              if (customer.billingAddress!.state != null)
                Text(customer.billingAddress!.state!, style: const TextStyle(fontSize: 10)),
              Text(
                '${customer.billingAddress!.zip ?? ''} ${customer.billingAddress!.city ?? ''}'.trim(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
              ),
              if (customer.billingAddress!.country != null)
                Text(customer.billingAddress!.country!, style: const TextStyle(fontSize: 10)),
            ],
            if (customer?.telephone != null)
              Text(
                '${customer!.telephonePrefix ?? ''} ${customer.telephone}'.trim(),
                style: const TextStyle(fontSize: 10),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 100,
      height: 60,
      color: Colors.grey[200],
      child: const Center(
        child: Text('LOGO', style: TextStyle(fontSize: 24, color: Colors.grey)),
      ),
    );
  }

  /// Job info section (date, job no, customer no, agent) aligned right
  Widget _buildJobInfoSection() {
    final data = jobData.data;
    final agent = data?.loggedUserId?.isNotEmpty == true ? data!.loggedUserId![0] : null;
    final customer = data?.customerDetails;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Labels
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (data?.createdAt != null || data?.updatedAt != null)
                const Text('Date:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
              if (data?.jobNo != null)
                const Text('Job No:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
              if (customer?.customerNo != null)
                const Text('Customer No:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
              if (agent?.fullName != null)
                const Text('Agent:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
            ],
          ),
          SizedBox(width: 8.w),
          // Values
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (data?.createdAt != null || data?.updatedAt != null)
                Text(
                  _formatDate(data!.updatedAt ?? data.createdAt!),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                ),
              if (data?.jobNo != null)
                Text(data!.jobNo!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
              if (customer?.customerNo != null)
                Text(customer!.customerNo!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
              if (agent?.fullName != null)
                Text(agent!.fullName!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }

  /// Barcode widget aligned right
  Widget _buildBarcode() {
    final jobNo = jobData.data?.jobNo ?? 'N/A';

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: jobNo,
          width: 100,
          height: 40,
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

  /// Device details section (gray/light gray background, side-by-side)
  Widget _buildDeviceDetails(DeviceData? deviceData, Device? device, Defect? defect) {
    final data = jobData.data;

    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBCBCB))),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column (labels) - Dark gray background
            Container(
              width: 100,
              padding: const EdgeInsets.all(5),
              color: const Color(0xFFCBCBCB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasDeviceDetails(deviceData, device))
                    const Text('Device details:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                  if (device?.accessories?.isNotEmpty == true) ...[
                    const SizedBox(height: 5),
                    const Text('Accessories:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                  ],
                  if (data?.physicalLocation != null) ...[
                    const SizedBox(height: 5),
                    const Text('Physical location:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                  ],
                  if (data?.jobTypes != null || defect?.reference != null) ...[
                    const SizedBox(height: 5),
                    const Text('Job type / Reference:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                  ],
                  if (defect?.description != null || defect?.defect?.isNotEmpty == true) ...[
                    const SizedBox(height: 5),
                    const Text('Description:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                  ],
                ],
              ),
            ),
            // Right column (values) - Light gray background
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xFFF0F0F0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasDeviceDetails(deviceData, device)) _buildDeviceDetailsText(deviceData, device),
                    if (device?.accessories?.isNotEmpty == true) ...[
                      const SizedBox(height: 5),
                      Text(
                        device!.accessories!.map((a) => a is Map ? (a['value'] ?? '') : a.toString()).join(', '),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                    if (data?.physicalLocation != null) ...[
                      const SizedBox(height: 5),
                      Text(data!.physicalLocation!, style: const TextStyle(fontSize: 10)),
                    ],
                    if (data?.jobTypes != null || defect?.reference != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${data?.jobTypes ?? ''}${defect?.reference != null ? ', ${defect!.reference}' : ''}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                    if (defect?.description != null || defect?.defect?.isNotEmpty == true) ...[
                      const SizedBox(height: 5),
                      Text(_buildDefectDescription(defect!), style: const TextStyle(fontSize: 10)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasDeviceDetails(DeviceData? deviceData, Device? device) {
    return (deviceData != null &&
            (deviceData.brand != null || deviceData.model != null || deviceData.serialNo != null)) ||
        (device != null && (device.brand != null || device.model != null || device.serialNo != null));
  }

  Widget _buildDeviceDetailsText(DeviceData? deviceData, Device? device) {
    final parts = <String>[];

    // Use deviceData or device for brand/model
    final brand = deviceData?.brand ?? device?.brand;
    final model = deviceData?.model ?? device?.model;
    final serialNo = deviceData?.serialNo ?? device?.serialNo;

    if (brand != null) parts.add(brand);
    if (model != null) parts.add(model);
    if (serialNo != null) parts.add('SN: $serialNo');

    // Use condition from either source
    final condition = deviceData?.condition ?? device?.condition;
    if (condition?.isNotEmpty == true) {
      parts.add(condition!.map((c) => c.value ?? '').join(', '));
    }

    return Text(parts.join(', '), style: const TextStyle(fontSize: 10));
  }

  String _buildDefectDescription(Defect defect) {
    final parts = <String>[];

    if (defect.defect?.isNotEmpty == true) {
      parts.add(defect.defect!.map((d) => d.value).join(', '));
    }

    if (defect.description != null) parts.add(defect.description!);

    return parts.join(', ');
  }

  /// Items/Services section with pricing
  Widget _buildItemsSection(List<dynamic> items) {
    final data = jobData.data;
    final subtotal = data?.subTotal ?? 0;
    final discount = data?.discount ?? 0;
    final total = data?.total ?? 0;

    return Column(
      children: [
        // Header
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
              Text('Service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Price', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 2),

        // Items list
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item['productName'] ?? item['name'] ?? 'Item', style: const TextStyle(fontSize: 9)),
                ),
                Text(_formatCurrency(item['price_incl_vat']), style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Financial summary (aligned right, 40% width)
        Align(
          alignment: Alignment.centerRight,
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth > 400 ? constraints.maxWidth * 0.4 : 200,
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', subtotal),
                  if (discount > 0) ...[const SizedBox(height: 10), _buildTotalRow('Discount', -discount)],
                  const SizedBox(height: 3),
                  Container(height: 1, color: const Color(0xFF707070)),
                  const SizedBox(height: 3),
                  _buildTotalRow('Total', total - discount, bold: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: bold ? 12 : 10, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(fontSize: bold ? 12 : 10, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
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

  /// QR code and signature section
  Widget _buildQRAndSignature() {
    final data = jobData.data;
    final trackingUrl =
        '$trackingDomain/${data?.jobTrackingNumber ?? ''}/order-tracking/${data?.sId ?? ''}?email=${data?.customerDetails?.email ?? ''}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // QR Code
        if (data?.jobTrackingNumber != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Repair Tracking', style: TextStyle(fontSize: 9, color: Color(0xFF2589F6))),
              const SizedBox(height: 4),
              QrImageView(data: trackingUrl, version: QrVersions.auto, size: 70),
              const SizedBox(height: 2),
              Text(data!.jobTrackingNumber!, style: const TextStyle(fontSize: 6, fontWeight: FontWeight.w500)),
            ],
          )
        else
          const SizedBox.shrink(),

        // Signature
        if (data?.signatureFilePath != null)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text('I agree to the terms and conditions:', style: TextStyle(fontSize: 10)),
                    // const SizedBox(width: 10),
                    Image.network(
                      '$baseUrl/file-upload/download/new?imagePath=${data!.signatureFilePath}',
                      height: 60,
                      width: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                Container(
                  width: 150.w,
                  alignment: Alignment.centerRight,
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF808080))),
                  ),
                  padding: const EdgeInsets.only(top: 5),
                  child: const Text('Date, Signature Client', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  /// Footer with company info, contact, bank details
  Widget _buildFooter(ReceiptFooter? footer) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Company Address
        _buildFooterColumn([
          if (footer?.address?.companyName != null) footer!.address!.companyName!,
          if (footer?.address?.street != null) '${footer!.address!.street} ${footer.address!.num ?? ''}'.trim(),
          if (footer?.address?.zip != null) '${footer!.address!.zip} ${footer.address!.city ?? ''}'.trim(),
          if (footer?.address?.country != null) footer!.address!.country!,
        ]),
        SizedBox(width: 8.w),

        // Contact Information
        _buildFooterColumn([
          if (footer?.contact?.ceo != null) 'CEO: ${footer!.contact!.ceo}',
          if (footer?.contact?.telephone != null) 'Tel: ${footer!.contact!.telephone}',
          if (footer?.contact?.email != null) 'Email: ${footer!.contact!.email}',
          if (footer?.contact?.website != null) 'Web: ${footer!.contact!.website}',
        ]),
        SizedBox(width: 8.w),

        // Bank Information
        _buildFooterColumn([
          if (footer?.bank?.bankName != null) footer!.bank!.bankName!,
          if (footer?.bank?.iban != null) 'IBAN: ${footer!.bank!.iban}',
          if (footer?.bank?.bic != null) 'BIC: ${footer!.bank!.bic}',
        ]),
      ],
    );
  }

  Widget _buildFooterColumn(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                item,
                style: const TextStyle(fontSize: 6, fontWeight: FontWeight.w400),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }

  /// HTML content renderer
  Widget _buildHtmlContent(String htmlContent) {
    // Remove placeholder variables like {salutation}, {contact_firstname}, {companyname}
    String cleanedContent = htmlContent
        .replaceAll(RegExp(r'\{salutation\},?\s*'), '')
        .replaceAll(RegExp(r'\{contact_firstname\}\s*'), '')
        .replaceAll(RegExp(r'\{companyname\}\s*'), '');

    return Html(
      data: cleanedContent,
      style: {
        "body": Style(fontSize: FontSize(8), margin: Margins.zero, padding: HtmlPaddings.zero),
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
        "a": Style(color: Colors.blue, textDecoration: TextDecoration.underline),
        "li": Style(fontSize: FontSize(8)),
        "ul": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
        "ol": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
      },
    );
  }

  /// Helper: Format company info line
  String _formatCompanyInfo(Address? address) {
    if (address == null) return '';

    final parts = <String>[];

    if (address.companyName != null) parts.add(address.companyName!);
    if (address.street != null) parts.add('${address.street} ${address.num ?? ''}'.trim());
    if (address.zip != null) parts.add('${address.zip} ${address.city ?? ''}'.trim());

    return parts.join(' • ');
  }

  /// Helper: Format customer name
  String _formatCustomerName(CustomerDetails customer) {
    final parts = <String>[];

    if (customer.salutation != null) parts.add(customer.salutation!);
    if (customer.firstName != null) parts.add(customer.firstName!);
    if (customer.lastName != null) parts.add(customer.lastName!);

    return parts.join(' ');
  }

  /// Helper: Format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Helper: Format currency
  String _formatCurrency(dynamic amount) {
    if (amount == null) return '€0.00';

    try {
      final numericAmount = amount is num ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
      return '€${numericAmount.toStringAsFixed(2)}';
    } catch (e) {
      return '€0.00';
    }
  }
}
