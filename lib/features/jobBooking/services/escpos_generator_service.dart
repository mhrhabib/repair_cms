import 'dart:convert';
import 'package:flutter/material.dart';

/// ESC/POS Generator Service - Pure ESC/POS commands (no image generation)
/// Generates raw ESC/POS byte commands for thermal receipt printing
class EscPosGeneratorService {
  // ESC/POS Command Constants
  static const eSC = 0x1B;
  static const gS = 0x1D;
  static const lF = 0x0A;
  static const cR = 0x0D;

  /// Generate complete thermal receipt as ESC/POS bytes
  static List<int> generateThermalReceipt({
    required Map<String, dynamic> jobData,
    required int paperWidth, // 58mm or 80mm
    bool includeQrCode = true,
  }) {
    debugPrint('🖨️ [EscPosGenerator] Generating receipt for paper width: ${paperWidth}mm');
    
    final List<int> bytes = [];

    // Initialize printer
    bytes.addAll(_initializePrinter());

    // Company header
    bytes.addAll(_printCompanyHeader(jobData));

    // Customer details
    bytes.addAll(_printCustomerDetails(jobData));

    // Job info row
    bytes.addAll(_printJobInfo(jobData));

    // Barcode (job number)
    final jobNo = jobData['jobNo'] ?? jobData['model'];
    if (jobNo != null && jobNo.isNotEmpty) {
      bytes.addAll(_printBarcode(jobNo));
    }

    // Job Receipt Title
    bytes.addAll(_printCenteredBoldText('Job Receipt'));

    // Salutation (plain text, no HTML)
    final salutation = _stripHtml(jobData['salutationHTMLmarkup'] ?? '');
    if (salutation.isNotEmpty) {
      bytes.addAll(_printText(salutation));
    }

    // Job Type
    bytes.addAll(_printSectionHeader('Job Type / Reference:'));
    bytes.addAll(_printText(jobData['jobTypes'] ?? ''));

    // Device Details
    final device = _getFirstDevice(jobData);
    if (device != null) {
      bytes.addAll(_printSectionHeader('Device Details:'));
      bytes.addAll(_printDeviceDetails(device));
    }

    // Defect/Symptom
    final defect = _getFirstDefect(jobData);
    if (defect != null) {
      bytes.addAll(_printSectionHeader('Symptom / Description:'));
      bytes.addAll(_printDefectDetails(defect));
    }

    // Physical Location
    final location = jobData['physicalLocation'];
    if (location != null && location.isNotEmpty) {
      bytes.addAll(_printSectionHeader('Physical Location:'));
      bytes.addAll(_printText(location));
    }

    // Services/Line Items
    final assignedItems = jobData['assignedItems'] as List?;
    if (assignedItems != null && assignedItems.isNotEmpty) {
      bytes.addAll(_printServicesSection(assignedItems));
      bytes.addAll(_printTotals(jobData));
    }

    bytes.addAll(_feedLines(1));

    // Terms and Conditions (plain text, no HTML)
    final terms = _stripHtml(jobData['termsAndConditionsHTMLmarkup'] ?? '');
    if (terms.isNotEmpty) {
      bytes.addAll(_printText(terms));
    }

    // Signature line (text only - no image)
    final signaturePath = jobData['signatureFilePath'];
    if (signaturePath != null && signaturePath.isNotEmpty) {
      bytes.addAll(_printSeparator());
      bytes.addAll(_printText('Customer Signature'));
      final customerName = _getCustomerName(jobData);
      if (customerName.isNotEmpty) {
        bytes.addAll(_printText(customerName));
      }
    }

    // QR Code for tracking
    if (includeQrCode) {
      final trackingNumber = jobData['jobTrackingNumber'];
      final jobId = jobData['sId'];
      final email = jobData['customerDetails']?['email'] ?? '';
      
      if (trackingNumber != null && jobId != null) {
        final qrUrl = 'https://customer-portal.repaircms.com/$trackingNumber/order-tracking/$jobId?email=$email';
        bytes.addAll(_printCenteredText('Scan to track your order:'));
        bytes.addAll(_printQrCode(qrUrl));
      }
    }

    // Footer contact info
    bytes.addAll(_printFooterContact(jobData));

    // Final feed and cut
    bytes.addAll(_feedLines(3));
    bytes.addAll(_cutPaper());

    debugPrint('✅ [EscPosGenerator] Generated ${bytes.length} bytes');
    return bytes;
  }

  /// Initialize printer: reset, set defaults
  static List<int> _initializePrinter() {
    debugPrint('🔧 [EscPosGenerator] Initializing printer');
    return [
      eSC, 0x40, // ESC @ - Initialize printer (reset to defaults)
      eSC, 0x61, 0x01, // ESC a 1 - Center alignment
    ];
  }

  /// Print company header (name, address, contact)
  static List<int> _printCompanyHeader(Map<String, dynamic> jobData) {
    final List<int> bytes = [];
    final receiptFooter = jobData['receiptFooter'];
    
    if (receiptFooter != null) {
      final address = receiptFooter['address'];
      if (address != null) {
        // Company name - bold, double height
        final companyName = address['companyName'] ?? '';
        if (companyName.isNotEmpty) {
          bytes.addAll(_printCenteredBoldText(companyName, doubleHeight: true));
        }

        // Address details
        final street = address['street'] ?? '';
        final num = address['num'] ?? '';
        final zip = address['zip'] ?? '';
        final city = address['city'] ?? '';
        
        if (street.isNotEmpty || num.isNotEmpty) {
          bytes.addAll(_printCenteredText('$street $num'.trim()));
        }
        if (zip.isNotEmpty || city.isNotEmpty) {
          bytes.addAll(_printCenteredText('$zip $city'.trim()));
        }
      }

      // Contact info
      final contact = receiptFooter['contact'];
      if (contact != null) {
        final phone = contact['telephone'] ?? '';
        final email = contact['email'] ?? '';
        final website = contact['website'] ?? '';
        
        if (phone.isNotEmpty) {
          bytes.addAll(_printCenteredText('Tel: $phone'));
        }
        if (email.isNotEmpty) {
          bytes.addAll(_printCenteredText(email));
        }
        if (website.isNotEmpty) {
          bytes.addAll(_printCenteredText(website));
        }
      }
    }

    bytes.addAll(_printSeparator());
    return bytes;
  }

  /// Print customer contact details
  static List<int> _printCustomerDetails(Map<String, dynamic> jobData) {
    final List<int> bytes = [];
    final customerDetails = jobData['customerDetails'];
    
    if (customerDetails != null) {
      bytes.addAll(_setLeftAlign());
      
      final salutation = customerDetails['salutation'] ?? '';
      final firstName = customerDetails['firstName'] ?? '';
      final lastName = customerDetails['lastName'] ?? '';
      final organization = customerDetails['organization'] ?? '';
      
      if (organization.isNotEmpty) {
        bytes.addAll(_printText(organization));
      }
      
      final fullName = '$salutation $firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        bytes.addAll(_printText(fullName));
      }

      final email = customerDetails['email'] ?? '';
      if (email.isNotEmpty) {
        bytes.addAll(_printText('Email: $email'));
      }

      final telephonePrefix = customerDetails['telephonePrefix'] ?? '';
      final telephone = customerDetails['telephone'] ?? '';
      if (telephone.isNotEmpty) {
        bytes.addAll(_printText('Tel: $telephonePrefix$telephone'));
      }

      bytes.addAll(_printSeparator());
    }
    
    return bytes;
  }

  /// Print job info (Job No, Date, Customer No)
  static List<int> _printJobInfo(Map<String, dynamic> jobData) {
    final List<int> bytes = [];
    bytes.addAll(_setLeftAlign());

    final jobNo = jobData['jobNo'] ?? jobData['model'] ?? 'N/A';
    bytes.addAll(_printText('Job No: $jobNo'));

    final createdAt = jobData['createdAt'];
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final formatted = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        bytes.addAll(_printText('Date: $formatted'));
      } catch (e) {
        bytes.addAll(_printText('Date: $createdAt'));
      }
    }

    final customerNo = jobData['customerDetails']?['customerNo'];
    if (customerNo != null && customerNo.isNotEmpty) {
      bytes.addAll(_printText('Customer No: $customerNo'));
    }

    return bytes;
  }

  /// Print barcode using ESC/POS commands (Code128)
  static List<int> _printBarcode(String data) {
    debugPrint('📊 [EscPosGenerator] Printing barcode: $data');
    final List<int> bytes = [];

    // Center alignment
    bytes.addAll([eSC, 0x61, 0x01]);

    // Set barcode height (default 162 dots, range: 1-255)
    bytes.addAll([gS, 0x68, 100]); // GS h n - Set barcode height

    // Set barcode width (default 3, range: 2-6)
    bytes.addAll([gS, 0x77, 3]); // GS w n - Set bar width

    // HRI position (print text below barcode)
    bytes.addAll([gS, 0x48, 0x02]); // GS H 2 - Print HRI below barcode

    // HRI font (Font A)
    bytes.addAll([gS, 0x66, 0x00]); // GS f 0 - Font A

    // Print Code128 barcode
    // GS k m n d1...dn (m=73 for CODE128)
    final barcodeData = utf8.encode(data);
    bytes.addAll([
      gS,
      0x6B,
      73, // CODE128
      barcodeData.length, // Length of data
      ...barcodeData, // Data bytes
    ]);

    return bytes;
  }

  /// Print QR code using ESC/POS QR commands
  static List<int> _printQrCode(String data) {
    debugPrint('📱 [EscPosGenerator] Printing QR code: ${data.substring(0, 50)}...');
    final List<int> bytes = [];

    // Center alignment
    bytes.addAll([eSC, 0x61, 0x01]);
    final qrData = utf8.encode(data);

    // QR Code Model: GS ( k pL pH cn fn n (fn=65)
    bytes.addAll([
      gS, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00, // Model 2
    ]);

    // QR Code Size: GS ( k pL pH cn fn n (fn=67)
    bytes.addAll([
      gS, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x08, // Size 8 (range: 1-16)
    ]);

    // QR Code Error Correction: GS ( k pL pH cn fn n (fn=69)
    bytes.addAll([
      gS, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x31, // Level M (48=L, 49=M, 50=Q, 51=H)
    ]);

    // Store QR data: GS ( k pL pH cn fn m d1...dk
    final pL = (qrData.length + 3) % 256;
    final pH = (qrData.length + 3) ~/ 256;
    bytes.addAll([
      gS, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30, // fn=80, m=48
      ...qrData,
    ]);

    // Print QR code: GS ( k pL pH cn fn m
    bytes.addAll([
      gS, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30, // fn=81, m=48
    ]);


    return bytes;
  }

  /// Print device details
  static List<int> _printDeviceDetails(Map<String, dynamic> device) {
    final List<int> bytes = [];
    bytes.addAll(_setLeftAlign());

    final brand = device['brand'] ?? '';
    final model = device['model'] ?? '';
    if (brand.isNotEmpty || model.isNotEmpty) {
      bytes.addAll(_printText('$brand $model'.trim()));
    }

    final condition = device['condition'] as List?;
    if (condition != null && condition.isNotEmpty) {
      final conditionStr = condition
          .map((c) => c['value'] ?? '')
          .where((v) => v.isNotEmpty)
          .join(', ');
      if (conditionStr.isNotEmpty) {
        bytes.addAll(_printText('Condition: $conditionStr'));
      }
    }

    return bytes;
  }

  /// Print defect/symptom details
  static List<int> _printDefectDetails(Map<String, dynamic> defect) {
    final List<int> bytes = [];
    bytes.addAll(_setLeftAlign());

    final defectList = defect['defect'] as List?;
    if (defectList != null && defectList.isNotEmpty) {
      final defectStr = defectList
          .map((d) => d['value'] ?? '')
          .where((v) => v.isNotEmpty)
          .join(', ');
      if (defectStr.isNotEmpty) {
        bytes.addAll(_printText(defectStr));
      }
    }

    final description = defect['description'];
    if (description != null && description.isNotEmpty) {
      bytes.addAll(_printText('Description: $description'));
    }

    return bytes;
  }

  /// Print services/line items section
  static List<int> _printServicesSection(List assignedItems) {
    final List<int> bytes = [];
    
    bytes.addAll(_setLeftAlign());
    bytes.addAll(_printSectionHeader('Services:'));
    bytes.addAll(_setCenterAlign());
    bytes.addAll(_printSeparator());
    bytes.addAll(_setLeftAlign());

    for (final item in assignedItems) {
      if (item is Map<String, dynamic>) {
        final name = item['productName'] ?? item['name'] ?? '';
        final price = item['price_incl_vat'] ?? item['salePriceIncVat'] ?? 0;
        
        if (name.isNotEmpty) {
          bytes.addAll(_setLeftAlign());
          bytes.addAll(_printText(name));
          bytes.addAll(_setRightAlign());
          bytes.addAll(_printText(_formatCurrency(price)));
        }
      }
    }

    bytes.addAll(_setCenterAlign());
    bytes.addAll(_printSeparator());
    bytes.addAll(_setLeftAlign());
    return bytes;
  }

  /// Print totals (subtotal, discount, total)
  static List<int> _printTotals(Map<String, dynamic> jobData) {
    final List<int> bytes = [];

    final assignedItems = jobData['assignedItems'] as List?;
    double subtotal = 0.0;
    
    if (assignedItems != null) {
      for (final item in assignedItems) {
        if (item is Map<String, dynamic>) {
          final price = item['price_incl_vat'] ?? item['salePriceIncVat'] ?? 0;
          subtotal += (price is num ? price.toDouble() : 0.0);
        }
      }
    }

    final discount = (jobData['discount'] ?? 0).toDouble();
    final total = subtotal - discount;

    // Print subtotal
    bytes.addAll(_setLeftAlign());
    bytes.addAll(_printText('Subtotal:'));
    bytes.addAll(_setRightAlign());
    bytes.addAll(_printText(_formatCurrency(subtotal)));

    // Print discount if applicable
    if (discount > 0) {
      bytes.addAll(_setLeftAlign());
      bytes.addAll(_printText('Discount:'));
      bytes.addAll(_setRightAlign());
      bytes.addAll(_printText('-${_formatCurrency(discount)}'));
    }

    // Print total (bold)
    bytes.addAll(_setLeftAlign());
    bytes.addAll(_setBoldOn());
    bytes.addAll(_printText('Total:'));
    bytes.addAll(_setRightAlign());
    bytes.addAll(_printText(_formatCurrency(total)));
    bytes.addAll(_setBoldOff());

    return bytes;
  }

  /// Print footer contact info
  static List<int> _printFooterContact(Map<String, dynamic> jobData) {
    final List<int> bytes = [];
    bytes.addAll(_printSeparator());
    bytes.addAll(_setCenterAlign());
    
    final receiptFooter = jobData['receiptFooter'];
    if (receiptFooter != null) {
      final contact = receiptFooter['contact'];
      if (contact != null) {
        bytes.addAll(_printText('For assistance, contact us:'));
        
        final phone = contact['telephone'];
        if (phone != null && phone.isNotEmpty) {
          bytes.addAll(_printText('Tel: $phone'));
        }
        
        final email = contact['email'];
        if (email != null && email.isNotEmpty) {
          bytes.addAll(_printText(email));
        }
      }

      // Bank details
      final bank = receiptFooter['bank'];
      if (bank != null) {
        bytes.addAll(_feedLines(1));
        final iban = bank['iban'];
        final bic = bank['bic'];
        
        if (iban != null && iban.isNotEmpty) {
          bytes.addAll(_printText('IBAN: $iban'));
        }
        if (bic != null && bic.isNotEmpty) {
          bytes.addAll(_printText('BIC: $bic'));
        }
      }
    }

    bytes.addAll(_feedLines(1));
    bytes.addAll(_printCenteredText('Thank you for your business!'));
    
    return bytes;
  }

  // === TEXT FORMATTING HELPERS ===

  /// Print regular text (left aligned) 
  static List<int> _printText(String text) {
    if (text.isEmpty) return [];
    final bytes = utf8.encode(text);
    return [...bytes, lF];
  }

  /// Print centered text
  static List<int> _printCenteredText(String text) {
    if (text.isEmpty) return [];
    return [
      ..._setCenterAlign(),
      ...utf8.encode(text),
      lF,
    ];
  }



  /// Print centered bold text
  static List<int> _printCenteredBoldText(String text, {bool doubleHeight = false}) {
    if (text.isEmpty) return [];
    return [
      ..._setCenterAlign(),
      ..._setBoldOn(),
      if (doubleHeight) ..._setDoubleHeightOn(),
      ...utf8.encode(text),
      lF,
      if (doubleHeight) ..._setDoubleHeightOff(),
      ..._setBoldOff(),
    ];
  }

  /// Print section header (bold, underlined)
  static List<int> _printSectionHeader(String text) {
    if (text.isEmpty) return [];
    return [
      ..._setLeftAlign(),
      ..._setBoldOn(),
      ...utf8.encode(text),
      lF,
      ..._setBoldOff(),
    ];
  }



  /// Print separator line
  static List<int> _printSeparator() {
    return [
      ..._setCenterAlign(),
      ...utf8.encode('--------------------------------'),
      lF,
    ];
  }

  // === ALIGNMENT COMMANDS ===

  static List<int> _setLeftAlign() => [eSC, 0x61, 0x00]; // ESC a 0
  static List<int> _setCenterAlign() => [eSC, 0x61, 0x01]; // ESC a 1
  static List<int> _setRightAlign() => [eSC, 0x61, 0x02]; // ESC a 2

  // === TEXT STYLE COMMANDS ===

  static List<int> _setBoldOn() => [eSC, 0x45, 0x01]; // ESC E 1
  static List<int> _setBoldOff() => [eSC, 0x45, 0x00]; // ESC E 0

  static List<int> _setDoubleHeightOn() => [eSC, 0x21, 0x10]; // ESC ! 16 (double height)
  static List<int> _setDoubleHeightOff() => [eSC, 0x21, 0x00]; // ESC ! 0 (normal)

  // === FEED & CUT COMMANDS ===

  static List<int> _feedLines(int lines) => [eSC, 0x64, lines]; // ESC d n
  static List<int> _cutPaper() => [gS, 0x56, 0x00]; // GS V 0 - Full cut

  // === UTILITY METHODS ===

  static Map<String, dynamic>? _getFirstDevice(Map<String, dynamic> jobData) {
    final devices = jobData['device'] as List?;
    return (devices != null && devices.isNotEmpty) ? devices[0] : null;
  }

  static Map<String, dynamic>? _getFirstDefect(Map<String, dynamic> jobData) {
    final defects = jobData['defect'] as List?;
    return (defects != null && defects.isNotEmpty) ? defects[0] : null;
  }

  static String _getCustomerName(Map<String, dynamic> jobData) {
    final customerDetails = jobData['customerDetails'];
    if (customerDetails == null) return '';
    
    final salutation = customerDetails['salutation'] ?? '';
    final firstName = customerDetails['firstName'] ?? '';
    final lastName = customerDetails['lastName'] ?? '';
    
    return '$salutation $firstName $lastName'.trim();
  }

  static String _formatCurrency(dynamic amount) {
    if (amount == null) return '€0.00';
    final value = amount is num ? amount.toDouble() : 0.0;
    return '€${value.toStringAsFixed(2)}';
  }

  /// Strip HTML tags from text (for salutation and terms)
  static String _stripHtml(String html) {
    if (html.isEmpty) return '';
    
    // Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    
    // Clean up extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return text;
  }
}
