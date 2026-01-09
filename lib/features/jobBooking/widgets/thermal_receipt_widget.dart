import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart'
    hide DateFormat;

/// Thermal receipt widget that matches the web React-PDF implementation
/// Width: 300 (equivalent to 80mm thermal paper)
class ThermalReceiptWidget extends StatelessWidget {
  final SingleJobModel jobData;
  final bool logoEnabled;
  final bool qrCodeEnabled;
  final bool enableTelephoneNumber;

  const ThermalReceiptWidget({
    super.key,
    required this.jobData,
    this.logoEnabled = true,
    this.qrCodeEnabled = true,
    this.enableTelephoneNumber = true,
  });

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '€0.00';
    final value = amount is num ? amount.toDouble() : 0.0;
    return '€${value.toStringAsFixed(2)}';
  }

  double _getTotalAmount() {
    final data = jobData.data;
    if (data?.assignedItems == null || data!.assignedItems!.isEmpty) {
      return data?.subTotal?.toDouble() ?? 0.0;
    }
    return data.assignedItems!.fold(0.0, (sum, item) {
      if (item is Map<String, dynamic>) {
        final price = item['price_incl_vat'] ?? item['salePriceIncVat'] ?? 0;
        return sum + (price is num ? price.toDouble() : 0.0);
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = jobData.data;
    if (data == null) {
      return const Center(child: Text('No job data available'));
    }

    final receiptFooter = data.receiptFooter;
    final customerDetails = data.customerDetails;
    final device = data.device?.isNotEmpty == true ? data.device![0] : null;
    final defect = data.defect?.isNotEmpty == true ? data.defect![0] : null;
    final totalAmount = _getTotalAmount();
    final discount = data.discount?.toDouble() ?? 0.0;
    final finalAmount = totalAmount - discount;

    // Build QR code URL for tracking
    final trackingQrUrl =
        'https://customer-portal.repaircms.com/${data.jobTrackingNumber ?? ''}/order-tracking/${data.sId}?email=${customerDetails?.email ?? ''}';

    return Container(
      width: 300,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // === LOGO ===
          if (logoEnabled && _hasLogo(receiptFooter)) ...[
            _buildLogo(receiptFooter!),
            const SizedBox(height: 15),
          ],

          // === COMPANY HEADER ===
          _buildCompanyHeader(receiptFooter),
          const SizedBox(height: 21),

          // === CUSTOMER CONTACT DETAILS ===
          _buildCustomerDetails(customerDetails),
          const SizedBox(height: 21),

          // === JOB INFO (Job No, Date, Customer No) ===
          _buildJobInfoRow(data, customerDetails),
          const SizedBox(height: 5),

          // === BARCODE ===
          if (data.jobNo != null && data.jobNo!.isNotEmpty) ...[
            _buildBarcode(data.jobNo!),
            const SizedBox(height: 6),
          ],

          // === JOB RECEIPT TITLE ===
          _buildText('Job Receipt', bold: true, fontSize: 16),
          const SizedBox(height: 6),

          // === SALUTATION HTML ===
          if (data.salutationHTMLmarkup != null &&
              data.salutationHTMLmarkup!.isNotEmpty) ...[
            _buildHtmlContent(data.salutationHTMLmarkup!),
            const SizedBox(height: 6),
          ],

          // === JOB TYPE / REFERENCE ===
          _buildSectionHeader('Job Type / Reference:'),
          _buildSectionContent(
            '${data.jobTypes ?? ''}${defect?.reference != null ? ', ${defect!.reference}' : ''}',
          ),
          const SizedBox(height: 6),

          // === DEVICE DETAILS ===
          if (_hasDeviceDetails(device)) ...[
            _buildSectionHeader('Device Details:'),
            _buildDeviceDetails(device!),
            const SizedBox(height: 6),
          ],

          // === SYMPTOM / DESCRIPTION ===
          if (_hasDefectInfo(defect)) ...[
            _buildSectionHeader('Symptom / Description:'),
            _buildDefectDetails(defect!),
            const SizedBox(height: 6),
          ],

          // === PHYSICAL LOCATION ===
          if (data.physicalLocation != null &&
              data.physicalLocation!.isNotEmpty) ...[
            _buildSectionHeader('Physical Location:'),
            _buildSectionContent(data.physicalLocation!),
            const SizedBox(height: 6),
          ],

          // === SERVICES / LINE ITEMS ===
          if (data.assignedItems != null && data.assignedItems!.isNotEmpty) ...[
            _buildServicesHeader(),
            const SizedBox(height: 5),
            _buildServicesList(data.assignedItems!),
            const SizedBox(height: 21),
            _buildTotals(totalAmount, discount, finalAmount),
          ],

          const SizedBox(height: 21),

          // === TERMS AND CONDITIONS HTML ===
          if (data.termsAndConditionsHTMLmarkup != null &&
              data.termsAndConditionsHTMLmarkup!.isNotEmpty) ...[
            _buildHtmlContent(data.termsAndConditionsHTMLmarkup!),
            const SizedBox(height: 8),
          ],

          // === SIGNATURE ===
          if (data.signatureFilePath != null &&
              data.signatureFilePath!.isNotEmpty) ...[
            _buildSignature(data.signatureFilePath!),
            const SizedBox(height: 4),
            _buildSignatureLine(customerDetails),
          ],

          const SizedBox(height: 15),

          // === QR CODE FOR TRACKING ===
          if (qrCodeEnabled &&
              data.jobTrackingNumber != null &&
              data.jobTrackingNumber!.isNotEmpty) ...[
            _buildTrackingQrCode(trackingQrUrl),
          ],

          const SizedBox(height: 32),

          // === FOOTER CONTACT INFO ===
          _buildFooterContactInfo(receiptFooter?.contact),

          const SizedBox(height: 15),

          // === OPENING HOURS ===
          Center(child: _buildText('Opening Hours', fontSize: 14)),
        ],
      ),
    );
  }

  // === HELPER METHODS ===

  bool _hasLogo(ReceiptFooter? footer) {
    if (footer == null) return false;
    return (footer.companyLogoURL != null &&
            footer.companyLogoURL!.isNotEmpty) ||
        (footer.companyLogo != null && footer.companyLogo!.isNotEmpty);
  }

  Widget _buildLogo(ReceiptFooter footer) {
    final logoUrl = footer.companyLogoURL ?? '';
    if (logoUrl.isEmpty) return const SizedBox.shrink();

    return Image.network(
      logoUrl.startsWith('http')
          ? logoUrl
          : 'https://api.repaircms.com/file-upload/download/new?imagePath=$logoUrl',
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildCompanyHeader(ReceiptFooter? footer) {
    if (footer == null) return const SizedBox.shrink();

    final address = footer.address;
    return Column(
      children: [
        if (address?.companyName != null && address!.companyName!.isNotEmpty)
          _buildText(address.companyName!),
        if (address?.street != null)
          _buildText('${address!.street ?? ''} ${address.num ?? ''}'.trim()),
        if (address?.zip != null || address?.city != null)
          _buildText('${address?.zip ?? ''} ${address?.city ?? ''}'.trim()),
        // These fields should come from company tax details
      ],
    );
  }

  Widget _buildCustomerDetails(CustomerDetails? customer) {
    if (customer == null) return const SizedBox.shrink();

    final billingAddress = customer.billingAddress;
    final hasStreet = billingAddress?.street?.isNotEmpty ?? false;
    final hasZip = billingAddress?.zip?.isNotEmpty ?? false;
    final hasCity = billingAddress?.city?.isNotEmpty ?? false;
    final hasState = billingAddress?.state?.isNotEmpty ?? false;
    final hasCountry = billingAddress?.country?.isNotEmpty ?? false;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization or Name
          if (customer.organization != null &&
              customer.organization!.isNotEmpty)
            _buildText(customer.organization!, align: TextAlign.left)
          else if ((customer.firstName?.isNotEmpty ?? false) ||
              (customer.lastName?.isNotEmpty ?? false))
            _buildText(
              '${customer.firstName ?? ''} ${customer.lastName ?? ''}'.trim(),
              align: TextAlign.left,
            ),
          // Telephone
          if (enableTelephoneNumber &&
              customer.telephone != null &&
              customer.telephone!.isNotEmpty)
            _buildText(
              '${customer.telephonePrefix ?? ''} ${customer.telephone}'.trim(),
              align: TextAlign.left,
            ),
          // Billing Address - Street
          if (hasStreet)
            _buildText(billingAddress!.street!, align: TextAlign.left),
          // Billing Address - State
          if (hasState)
            _buildText(billingAddress!.state!, align: TextAlign.left),
          // Billing Address - Zip and City
          if (hasZip || hasCity)
            _buildText(
              '${billingAddress?.zip ?? ''} ${billingAddress?.city ?? ''}'
                  .trim(),
              align: TextAlign.left,
            ),
          // Billing Address - Country (translated if needed)
          if (hasCountry)
            _buildText(billingAddress!.country!, align: TextAlign.left),
        ],
      ),
    );
  }

  Widget _buildJobInfoRow(Data data, CustomerDetails? customer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('Job No:', align: TextAlign.left),
            _buildText('Date:', align: TextAlign.left),
            _buildText('Customer No:', align: TextAlign.left),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildText(data.jobNo ?? data.sId ?? '', align: TextAlign.right),
            _buildText(_formatDate(data.createdAt), align: TextAlign.right),
            _buildText(customer?.customerNo ?? '', align: TextAlign.right),
          ],
        ),
      ],
    );
  }

  Widget _buildBarcode(String jobNo) {
    return Center(
      child: BarcodeWidget(
        barcode: Barcode.code128(),
        data: jobNo,
        width: jobNo.length >= 15 ? 130 : 100,
        height: jobNo.length >= 15 ? 80 : 50,
        drawText: true,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _buildText(content, align: TextAlign.left),
      ),
    );
  }

  bool _hasDeviceDetails(Device? device) {
    if (device == null) return false;
    return device.model != null ||
        device.serialNo != null ||
        (device.condition != null && device.condition!.isNotEmpty);
  }

  Widget _buildDeviceDetails(Device device) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (device.model != null)
            _buildText(device.model!, align: TextAlign.left),
          if (device.serialNo != null && device.serialNo!.isNotEmpty)
            _buildText('Serial No: ${device.serialNo}', align: TextAlign.left),
          if (device.condition != null && device.condition!.isNotEmpty) ...[
            _buildText('Conditions:', align: TextAlign.left, fontSize: 14),
            ...device.condition!.map(
              (c) => _buildText(
                '${c.value ?? ''},',
                align: TextAlign.left,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasDefectInfo(Defect? defect) {
    if (defect == null) return false;
    return (defect.defect != null && defect.defect!.isNotEmpty) ||
        (defect.description != null && defect.description!.isNotEmpty);
  }

  Widget _buildDefectDetails(Defect defect) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (defect.defect != null)
            ...defect.defect!.map(
              (d) => _buildText('${d.value ?? ''}, ', align: TextAlign.left),
            ),
          if (defect.description != null && defect.description!.isNotEmpty)
            _buildText(defect.description!, align: TextAlign.left),
        ],
      ),
    );
  }

  Widget _buildServicesHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF707070))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildText('Service', bold: true),
          _buildText('Price', bold: true),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<dynamic> items) {
    return Column(
      children: items.map((item) {
        String productName = '';
        double price = 0.0;

        if (item is Map<String, dynamic>) {
          productName = item['productName'] ?? item['name'] ?? '';
          final priceValue =
              item['price_incl_vat'] ?? item['salePriceIncVat'] ?? 0;
          price = priceValue is num ? priceValue.toDouble() : 0.0;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildText(productName, align: TextAlign.left),
              ),
              _buildText(_formatCurrency(price)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotals(double totalAmount, double discount, double finalAmount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildText('Subtotal', bold: true),
            _buildText(_formatCurrency(totalAmount), bold: true),
          ],
        ),
        if (discount > 0) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText('Discount', bold: true),
              _buildText('- ${_formatCurrency(discount)}', bold: true),
            ],
          ),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 1,
          color: const Color(0xFF707070),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildText('Total', bold: true),
            _buildText(_formatCurrency(finalAmount), bold: true),
          ],
        ),
      ],
    );
  }

  Widget _buildHtmlContent(String html) {
    return Align(
      alignment: Alignment.centerLeft,
      child: HtmlWidget(html, textStyle: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildSignature(String signaturePath) {
    final url = signaturePath.startsWith('http')
        ? signaturePath
        : 'https://api.repaircms.com/file-upload/download/new?imagePath=$signaturePath';
    return Center(
      child: Image.network(
        url,
        height: 60,
        width: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSignatureLine(CustomerDetails? customer) {
    return Center(
      child: Container(
        width: 186,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF707070))),
        ),
        padding: const EdgeInsets.only(top: 4),
        child: _buildText(
          'Date / Signature ${customer?.firstName ?? ''} ${customer?.lastName ?? ''}'
              .trim(),
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTrackingQrCode(String url) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Repair Tracking',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 10,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 8, color: Colors.blue[600]),
          ],
        ),
        const SizedBox(height: 2),
        QrImageView(
          data: url,
          version: QrVersions.auto,
          size: 150,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
        ),
      ],
    );
  }

  Widget _buildFooterContactInfo(ContactInfo? contact) {
    if (contact == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (contact.telephone != null && contact.telephone!.isNotEmpty)
          _buildText('Tel.: ${contact.telephone}'),
        if (contact.email != null && contact.email!.isNotEmpty)
          _buildText(contact.email!),
        if (contact.website != null && contact.website!.isNotEmpty)
          _buildText(contact.website!),
      ],
    );
  }

  Widget _buildText(
    String text, {
    bool bold = false,
    double fontSize = 14,
    Color? color,
    TextAlign align = TextAlign.center,
  }) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        color: color ?? Colors.black87,
        height: 1.4,
      ),
    );
  }
}
