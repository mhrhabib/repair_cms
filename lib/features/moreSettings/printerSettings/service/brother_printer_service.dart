import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/set_up_di.dart';
import 'package:printing/printing.dart' as printing;
import 'printer_settings_service.dart';

import 'base_printer_service.dart';

/// Lightweight network printer service (raw TCP/IPP) that works on the iOS simulator
/// Supports both raw TCP (port 9100) and IPP (port 631) protocols
/// This is intended as a simulator-friendly replacement for the device-only
/// `another_brother` SDK. For full ESC/POS features or label printing support you should integrate a
/// platform-specific plugin or add an ESC/POS utility package.
class BrotherPrinterService implements BasePrinterService {
  static final BrotherPrinterService _instance = BrotherPrinterService._internal();
  factory BrotherPrinterService() => _instance;
  BrotherPrinterService._internal();

  final _settingsService = PrinterSettingsService();
  Talker get _talker => SetUpDI.getIt<Talker>();

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // Get printer model to determine if it's a TD series
    final printers = _settingsService.getPrinters('label');
    String modelString = '';
    try {
      final printer = printers.firstWhere((p) => p.ipAddress == ipAddress);
      modelString = printer.printerModel?.toUpperCase() ?? '';
    } catch (e) {
      // Printer not found in config, assume not TD
    }

    // TD series printers MUST use raw TCP with raster commands, NOT IPP
    // IPP sends text/plain which TD printers cannot process
    final isTDPrinter = modelString.startsWith('TD-');

    if (isTDPrinter) {
      // Force raw TCP for TD printers, ignore port parameter
      _talker.debug('[BrotherRawTCP] TD printer detected: $modelString - forcing raw TCP mode (port 9100)');
      // Don't use IPP even if port 631 is configured
      return _printViaTDRaster(ipAddress, text, timeout);
    }

    // For QL/PT series, use IPP if port 631 is specified
    if (port == 631) {
      return _printViaIPP(ipAddress, text, timeout);
    }

    // Otherwise use raw TCP with raster commands
    return _printViaTDRaster(ipAddress, text, timeout);
  }

  /// Print via raw TCP using Brother raster commands (for TD series)
  Future<PrinterResult> _printViaTDRaster(String ipAddress, String text, Duration timeout) async {
    try {
      _talker.info('[BrotherRawTCP: $ipAddress] Starting Brother raw TCP print');

      // Get label size configuration
      final labelSize = _settingsService.getDefaultPrinter('label')?.labelSize;
      final labelWidth = labelSize?.width ?? 62; // Default to 62mm
      final labelHeight = labelSize?.height ?? 100; // Default to 100mm

      _talker.debug('[BrotherRawTCP] Label size: ${labelWidth}x${labelHeight}mm');

      final socket = await Socket.connect(ipAddress, 9100, timeout: timeout);

      // Build Brother raster command sequence for TD-2/TD-4 series
      final bytes = _buildTDRasterCommands(text, labelWidth, labelHeight);

      _talker.debug('[BrotherRawTCP] Sending ${bytes.length} bytes to printer');
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1000)); // Wait for printer to process
      socket.destroy();

      _talker.info('[BrotherRawTCP: $ipAddress] ✅ Printed successfully (raw TCP)');
      return PrinterResult(success: true, message: 'Printed (raw TCP)', code: 0);
    } catch (e) {
      _talker.error('[BrotherRawTCP: $ipAddress] ❌ Print error: $e');
      return PrinterResult(success: false, message: 'Print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return printThermalReceipt(ipAddress: ipAddress, text: text, port: port, timeout: timeout);
  }

  @override
  Future<PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      _talker.info('[BrotherRawTCP: $ipAddress] Printing device label');
      // Step 1: Connect to printer
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      // Step 2: Build ESC/POS commands
      final List<int> bytes = [];

      // ESC/POS Commands
      const esc = 0x1B;
      // ignore: unused_local_variable
      const gs = 0x1D; // Reserved for future GS commands

      // Initialize printer
      bytes.addAll([esc, 0x40]); // ESC @ - Initialize

      // Set to standard mode
      bytes.addAll([esc, 0x69, 0x61, 0x00]); // ESC i a 0

      // Bold ON
      bytes.addAll([esc, 0x45, 0x01]); // ESC E 1

      // Print title
      bytes.addAll(utf8.encode('DEVICE LABEL\n'));

      // Bold OFF
      bytes.addAll([esc, 0x45, 0x00]); // ESC E 0

      // Line separator
      bytes.addAll(utf8.encode('===============\n'));

      // Print data fields
      labelData.forEach((key, value) {
        bytes.addAll(utf8.encode('$key: $value\n'));
      });

      // Line separator
      bytes.addAll(utf8.encode('===============\n'));

      // Line feeds
      bytes.addAll([0x0A, 0x0A]);

      // Form feed to eject label
      bytes.addAll([0x0C]); // Form feed

      // Step 3: Send to printer
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      socket.destroy();

      _talker.info('[BrotherRawTCP: $ipAddress] ✅ Device label printed successfully');
      return PrinterResult(success: true, message: 'Device label printed successfully', code: 0);
    } catch (e) {
      _talker.error('[BrotherRawTCP: $ipAddress] ❌ Device label print error: $e');
      return PrinterResult(success: false, message: 'Device label print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
  }) async {
    try {
      _talker.info('[BrotherRawTCP: $ipAddress] Starting TD image print (QR code/label)');

      // Get label size configuration
      final labelSize = _settingsService.getDefaultPrinter('label')?.labelSize;
      final labelWidth = labelSize?.width ?? 62;
      final labelHeight = labelSize?.height ?? 100;

      _talker.debug('[BrotherRawTCP] Label size: ${labelWidth}x${labelHeight}mm');

      // Check if input is PDF
      final isPdf =
          imageBytes.length > 4 &&
          imageBytes[0] == 0x25 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x44 &&
          imageBytes[3] == 0x46;

      ui.Image? uiImage;

      if (isPdf) {
        // Rasterize PDF to image
        _talker.debug('[BrotherRawTCP] Rasterizing PDF to image');
        await for (var page in printing.Printing.raster(imageBytes, pages: [0], dpi: 203)) {
          uiImage = await page.toImage();
          break; // Only process first page
        }
      } else {
        // Decode image bytes
        _talker.debug('[BrotherRawTCP] Decoding image');
        final codec = await ui.instantiateImageCodec(imageBytes);
        final frame = await codec.getNextFrame();
        uiImage = frame.image;
      }

      if (uiImage == null) {
        return PrinterResult(success: false, message: 'Failed to process image', code: -1);
      }

      // Convert image to raster data
      final bytes = await _buildTDRasterFromImage(uiImage, labelWidth, labelHeight);

      final socket = await Socket.connect(ipAddress, 9100, timeout: const Duration(seconds: 5));
      _talker.debug('[BrotherRawTCP] Sending ${bytes.length} bytes to printer');

      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1000));
      socket.destroy();

      _talker.info('[BrotherRawTCP: $ipAddress] ✅ Image printed successfully (raw TCP)');
      return PrinterResult(success: true, message: 'Image printed (raw TCP)', code: 0);
    } catch (e, st) {
      _talker.error('[BrotherRawTCP: $ipAddress] ❌ Image print error: $e');
      debugPrint('Stack trace: $st');
      return PrinterResult(success: false, message: 'Image print error: $e', code: -1);
    }
  }

  @override
  Future<PrinterStatus> getPrinterStatus({required String ipAddress, int port = 9100}) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 4));
      socket.destroy();
      return PrinterStatus(isConnected: true, message: 'Printer reachable', code: 0);
    } catch (e) {
      return PrinterStatus(isConnected: false, message: 'Printer not reachable: $e', code: -1);
    }
  }

  /// Print via IPP (Internet Printing Protocol) - Port 631
  /// More modern and reliable than raw TCP for many printers
  Future<PrinterResult> _printViaIPP(String ipAddress, String text, Duration timeout) async {
    try {
      _talker.info('[BrotherIPP: $ipAddress:631] Starting Brother IPP print');

      final socket = await Socket.connect(ipAddress, 631, timeout: timeout);

      // Build IPP Print-Job request
      final List<int> ippRequest = [];

      // IPP version 1.1, Print-Job operation
      ippRequest.addAll([0x01, 0x01]); // Version 1.1
      ippRequest.addAll([0x00, 0x02]); // Operation: Print-Job
      ippRequest.addAll([0x00, 0x00, 0x00, 0x01]); // Request ID

      // Operation attributes tag
      ippRequest.add(0x01);

      // attributes-charset
      ippRequest.add(0x47); // charset tag
      ippRequest.addAll([0x00, 0x12]); // name length
      ippRequest.addAll(utf8.encode('attributes-charset'));
      ippRequest.addAll([0x00, 0x05]); // value length
      ippRequest.addAll(utf8.encode('utf-8'));

      // attributes-natural-language
      ippRequest.add(0x48); // naturalLanguage tag
      ippRequest.addAll([0x00, 0x1b]); // name length
      ippRequest.addAll(utf8.encode('attributes-natural-language'));
      ippRequest.addAll([0x00, 0x05]); // value length
      ippRequest.addAll(utf8.encode('en-us'));

      // printer-uri
      ippRequest.add(0x45); // uri tag
      ippRequest.addAll([0x00, 0x0b]); // name length
      ippRequest.addAll(utf8.encode('printer-uri'));
      final printerUri = 'ipp://$ipAddress/ipp/print';
      final uriBytes = utf8.encode(printerUri);
      ippRequest.addAll([uriBytes.length >> 8, uriBytes.length & 0xFF]);
      ippRequest.addAll(uriBytes);

      // requesting-user-name
      ippRequest.add(0x42); // nameWithoutLanguage tag
      ippRequest.addAll([0x00, 0x14]); // name length
      ippRequest.addAll(utf8.encode('requesting-user-name'));
      final userName = utf8.encode('RepairCMS');
      ippRequest.addAll([0x00, userName.length]);
      ippRequest.addAll(userName);

      // job-name
      ippRequest.add(0x42); // nameWithoutLanguage tag
      ippRequest.addAll([0x00, 0x08]); // name length
      ippRequest.addAll(utf8.encode('job-name'));
      final jobName = utf8.encode('Label Print');
      ippRequest.addAll([0x00, jobName.length]);
      ippRequest.addAll(jobName);

      // document-format
      ippRequest.add(0x49); // mimeMediaType tag
      ippRequest.addAll([0x00, 0x0f]); // name length
      ippRequest.addAll(utf8.encode('document-format'));
      final docFormat = utf8.encode('text/plain');
      ippRequest.addAll([0x00, docFormat.length]);
      ippRequest.addAll(docFormat);

      // End of attributes
      ippRequest.add(0x03);

      // Add the actual print data
      final textBytes = utf8.encode(text);
      ippRequest.addAll(textBytes);

      _talker.debug('[BrotherIPP] Sending ${ippRequest.length} bytes IPP request');

      socket.add(Uint8List.fromList(ippRequest));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for printer response
      socket.destroy();

      _talker.info('[BrotherIPP: $ipAddress:631] ✅ Printed successfully (IPP)');
      return PrinterResult(success: true, message: 'Printed (IPP)', code: 0);
    } catch (e) {
      _talker.error('[BrotherIPP: $ipAddress:631] ❌ IPP print error: $e');
      return PrinterResult(success: false, message: 'IPP print error: $e', code: -1);
    }
  }

  /// Build Brother TD-2/TD-4 series raster commands
  /// Supports both TD-2 (203 DPI) and TD-4 (300 DPI) series printers
  List<int> _buildTDRasterCommands(String text, int labelWidth, int labelHeight) {
    final List<int> bytes = [];
    const esc = 0x1B;

    // 1. Invalidate command - 100 null bytes to clear previous job
    for (var i = 0; i < 100; i++) {
      bytes.add(0x00);
    }

    // 2. Initialize printer
    bytes.addAll([esc, 0x40]); // ESC @

    // 3. Enter raster graphics mode
    bytes.addAll([esc, 0x69, 0x61, 0x01]); // ESC i a 1

    // 4. Set print information command (ESC i z)
    bytes.addAll([esc, 0x69, 0x7A]);

    // Print information flags
    final validFlag = 0x80; // Bit 7: Valid command
    final autoCut = 0x02; // Bit 1: Auto-cut enabled
    final mirrorOff = 0x00; // Bit 0: No mirror printing
    bytes.add(validFlag | autoCut | mirrorOff);

    // Media width in mm (used for TD-4, ignored by TD-2)
    bytes.add(labelWidth & 0xFF);

    // Media length in mm (0 = continuous, or actual height)
    bytes.add(labelHeight & 0xFF);

    // Raster lines count (0 = auto)
    bytes.addAll([0x00, 0x00, 0x00, 0x00]);

    // Starting page (always 0)
    bytes.add(0x00);

    // Additional padding
    bytes.add(0x00);

    // 5. Set page orientation (portrait)
    bytes.addAll([esc, 0x69, 0x4C, 0x00]); // ESC i L 0 (portrait)

    // 6. Set left margin to 0
    bytes.addAll([esc, 0x69, 0x64, 0x00, 0x00]); // ESC i d

    // 7. Set compression mode (M command - no compression)
    bytes.addAll([0x4D, 0x00]); // M 0x00

    // 8. Generate raster data from text
    final widthDots = labelWidth * 8; // 8 dots per mm at 203 DPI
    final lineBytes = (widthDots / 8).ceil();

    final lines = text.split('\n');
    final maxLines = 20; // Maximum lines to print

    for (var lineIndex = 0; lineIndex < lines.length && lineIndex < maxLines; lineIndex++) {
      final line = lines[lineIndex];

      // Each character is 8 pixels tall
      for (var row = 0; row < 12; row++) {
        // 12 pixel rows per text line
        bytes.add(0x67); // 'g' raster line command
        bytes.add(0x00); // No additional flags

        // Line length in bytes
        bytes.add(lineBytes & 0xFF);

        // Generate pixel data for this row
        final pixelData = List<int>.filled(lineBytes, 0x00);

        // Simple block-based text rendering
        if (row >= 2 && row <= 9) {
          // Render text in middle rows
          for (var charIndex = 0; charIndex < line.length; charIndex++) {
            final byteIndex = charIndex * 2; // 2 bytes per character (16 pixels wide)
            if (byteIndex < lineBytes) {
              pixelData[byteIndex] = 0xFF; // Full black pixels
              if (byteIndex + 1 < lineBytes) {
                pixelData[byteIndex + 1] = 0xF0; // Partial pixels for spacing
              }
            }
          }
        }

        bytes.addAll(pixelData);
      }

      // Add 2 blank rows between text lines for spacing
      for (var i = 0; i < 2; i++) {
        bytes.add(0x67); // 'g' command
        bytes.add(0x00);
        bytes.add(lineBytes & 0xFF);
        bytes.addAll(List<int>.filled(lineBytes, 0x00));
      }
    }

    // 9. Print command
    bytes.add(0x1A); // SUB - Print and feed

    // 10. Optional: Add a form feed to ensure label ejects
    bytes.add(0x0C); // FF - Form feed

    return bytes;
  }

  /// Convert a Flutter Image to Brother TD raster format
  /// This is used for printing QR codes and image-based labels
  Future<List<int>> _buildTDRasterFromImage(ui.Image image, int labelWidth, int labelHeight) async {
    final List<int> bytes = [];
    const esc = 0x1B;

    // Calculate dimensions
    final widthDots = labelWidth * 8; // 8 dots per mm at 203 DPI
    final heightDots = labelHeight * 8;
    final lineBytes = (widthDots / 8).ceil();

    _talker.info('[BrotherRawTCP] 📐 Label config: ${labelWidth}x${labelHeight}mm');
    _talker.info('[BrotherRawTCP] 📐 Raster dimensions: ${widthDots}x$heightDots dots');
    _talker.info('[BrotherRawTCP] 📐 Line bytes: $lineBytes bytes per line');

    // 1. Invalidate command - 100 null bytes
    for (var i = 0; i < 100; i++) {
      bytes.add(0x00);
    }

    // 2. Initialize
    bytes.addAll([esc, 0x40]); // ESC @

    // 3. Enter raster mode
    bytes.addAll([esc, 0x69, 0x61, 0x01]); // ESC i a 1

    // 4. Set print information
    bytes.addAll([esc, 0x69, 0x7A]);
    bytes.add(0x80 | 0x02 | 0x00); // Valid | auto-cut | high quality
    bytes.add(labelWidth & 0xFF);
    bytes.add(labelHeight & 0xFF);
    bytes.addAll([0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);

    // 5. Set orientation
    bytes.addAll([esc, 0x69, 0x4C, 0x00]); // Portrait

    // 6. Set margins
    bytes.addAll([esc, 0x69, 0x64, 0x00, 0x00]); // Left margin = 0

    // 7. No compression
    bytes.addAll([0x4D, 0x00]); // M 0x00

    // 8. Convert image to raster data
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception('Failed to convert image to byte data');
    }

    final imageWidth = image.width;
    final imageHeight = image.height;
    _talker.info('[BrotherRawTCP] 🖼️ Source image: ${imageWidth}x$imageHeight pixels');

    // Scale factors
    final scaleX = widthDots / imageWidth;
    final scaleY = heightDots / imageHeight;
    _talker.info('[BrotherRawTCP] 📊 Scale factors: X=$scaleX, Y=$scaleY');

    // Process each raster line
    for (var y = 0; y < heightDots; y++) {
      bytes.add(0x67); // 'g' command
      bytes.add(0x00); // Flags
      bytes.add(lineBytes & 0xFF); // Line length

      // Create pixel data for this line
      final pixelData = List<int>.filled(lineBytes, 0x00);

      for (var x = 0; x < widthDots; x++) {
        // Map to source image coordinates
        final srcX = (x / scaleX).floor().clamp(0, imageWidth - 1);
        final srcY = (y / scaleY).floor().clamp(0, imageHeight - 1);

        // Get pixel from source image (RGBA)
        final pixelIndex = (srcY * imageWidth + srcX) * 4;
        final r = byteData.getUint8(pixelIndex);
        final g = byteData.getUint8(pixelIndex + 1);
        final b = byteData.getUint8(pixelIndex + 2);
        final a = byteData.getUint8(pixelIndex + 3);

        // Convert to grayscale (0-255)
        final gray = ((r * 0.299) + (g * 0.587) + (b * 0.114)).round();

        // Log first few pixels for debugging
        if (y < 3 && x < 8) {
          _talker.debug('[BrotherRawTCP] 🎨 Pixel[$x,$y]: R=$r G=$g B=$b A=$a Gray=$gray');
        }

        // If pixel is transparent, treat as white
        // Otherwise use grayscale threshold
        final isBlack = a >= 128 && gray < 128;

        if (isBlack) {
          final byteIndex = x ~/ 8;
          final bitIndex = x % 8; // LSB first (0-7 left to right)
          pixelData[byteIndex] |= (1 << bitIndex);
        }
      }

      // Log first line sample
      if (y < 3) {
        final sample = pixelData.take(8).map((b) => b.toRadixString(2).padLeft(8, '0')).join(' ');
        _talker.debug('[BrotherRawTCP] 📋 Line $y sample: $sample');
      }

      bytes.addAll(pixelData);
    }

    // 9. Print and feed
    bytes.add(0x1A); // SUB

    // 10. Form feed
    bytes.add(0x0C); // FF

    _talker.info('[BrotherRawTCP] ✅ Generated ${bytes.length} bytes of raster data');
    _talker.info('[BrotherRawTCP] 📊 Raster lines: $heightDots, Bytes per line: $lineBytes');
    _talker.info('[BrotherRawTCP] 🎯 Expected label: ${labelWidth}x${labelHeight}mm');
    return bytes;
  }
}
