import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:talker_flutter/talker_flutter.dart';
import 'base_printer_service.dart';
import '../../../../set_up_di.dart';

/// Dedicated thermal receipt printer service for image-based printing
/// Supports Epson, Star, Xprinter and other ESC/POS compatible thermal printers
class ThermalReceiptPrinterService {
  static final ThermalReceiptPrinterService _instance =
      ThermalReceiptPrinterService._internal();
  factory ThermalReceiptPrinterService() => _instance;
  ThermalReceiptPrinterService._internal();

  Talker get _talker => SetUpDI.getIt<Talker>();

  /// Print thermal receipt as image with logos, QR codes, and barcodes
  /// Uses ESC/POS raster graphics commands
  Future<PrinterResult> printThermalImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
    int paperWidth = 80, // 80mm or 58mm
  }) async {
    final startTime = DateTime.now();
    _talker.info(
      '🖨️ [ThermalImage] Starting print to $ipAddress:$port (${paperWidth}mm paper)',
    );
    _talker.debug('📦 Image data: ${imageBytes.length} bytes');

    try {
      debugPrint(
        '🖨️ [ThermalImage: $ipAddress] Starting thermal receipt image print',
      );
      debugPrint('📏 Paper width: ${paperWidth}mm');

      // Decode the image
      _talker.debug('🔄 Decoding image codec...');
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      _talker.debug('✅ Decoded: ${uiImage.width}x${uiImage.height} pixels');

      // Convert to image package format for processing
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final imgLib = img.Image.fromBytes(
        width: uiImage.width,
        height: uiImage.height,
        bytes: byteData.buffer,
        numChannels: 4,
      );

      // Calculate width in pixels based on paper size
      // 80mm = 576 pixels at 203 DPI, 58mm = 420 pixels at 203 DPI
      final widthPixels = paperWidth == 80 ? 576 : 420;
      _talker.debug(
        '📏 Target width: $widthPixels pixels for ${paperWidth}mm paper',
      );

      // Resize image to fit thermal paper width
      _talker.debug('🔄 Resizing image...');
      final resizedImg = img.copyResize(
        imgLib,
        width: widthPixels,
        maintainAspect: true,
      );

      // Convert to monochrome (black and white) for thermal printing
      _talker.debug('🔄 Converting to monochrome...');
      final bwImg = img.grayscale(resizedImg);

      debugPrint(
        '📐 Image size: ${resizedImg.width}x${resizedImg.height} pixels',
      );
      _talker.info(
        '✅ Processed: ${resizedImg.width}x${resizedImg.height} pixels (B&W)',
      );

      // Build ESC/POS raster graphics commands
      _talker.debug('🔄 Building ESC/POS raster commands...');
      final commands = _buildESCPOSRasterCommands(bwImg);
      _talker.info('📋 Generated ${commands.length} bytes of ESC/POS commands');

      // Send to printer
      _talker.debug('🌐 Connecting to $ipAddress:$port...');
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 5),
      );
      debugPrint('🌐 Connected to printer, sending ${commands.length} bytes');
      _talker.info('✅ Socket connected');

      _talker.debug('📤 Sending data to printer...');
      socket.add(commands);
      await socket.flush();
      await socket.close();
      _talker.debug('🔌 Socket closed');

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ [ThermalImage: $ipAddress] Print successful');
      _talker.info(
        '✅ Print completed successfully in ${duration.inMilliseconds}ms',
      );
      return PrinterResult(
        success: true,
        message: 'Thermal receipt printed successfully',
        code: 0,
      );
    } catch (e, st) {
      debugPrint('❌ [ThermalImage: $ipAddress] Error: $e');
      debugPrint('Stack trace: $st');
      _talker.error('❌ Print failed: $e');
      _talker.debug('Stack trace: $st');
      return PrinterResult(
        success: false,
        message: 'Print error: $e',
        code: -1,
      );
    }
  }

  /// Build ESC/POS raster graphics commands for thermal printing
  List<int> _buildESCPOSRasterCommands(img.Image image) {
    final commands = <int>[];

    // ESC @ - Initialize printer
    commands.addAll([0x1B, 0x40]);

    // ESC a 1 - Center alignment
    commands.addAll([0x1B, 0x61, 0x01]);

    // Process image line by line
    final width = image.width;
    final height = image.height;
    final bytesPerLine = (width + 7) ~/ 8; // Round up to nearest byte

    for (int y = 0; y < height; y++) {
      // GS v 0 - Print raster bit image
      commands.addAll([
        0x1D, 0x76, 0x30, 0x00, // GS v 0 m (normal mode)
        bytesPerLine & 0xFF,
        (bytesPerLine >> 8) & 0xFF, // xL xH (width in bytes)
        0x01, 0x00, // yL yH (height = 1 line)
      ]);

      // Convert line to monochrome bits
      final lineBytes = <int>[];
      for (int x = 0; x < width; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final px = x + bit;
          if (px < width) {
            final pixel = image.getPixel(px, y);
            // Get luminance (0-255), invert for thermal (black = 1)
            final luminance = pixel.r.toInt();
            if (luminance < 128) {
              // Black pixel
              byte |= (0x80 >> bit);
            }
          }
        }
        lineBytes.add(byte);
      }
      commands.addAll(lineBytes);
    }

    // Feed paper
    commands.addAll([0x1B, 0x64, 0x03]); // ESC d 3 - Feed 3 lines

    // Cut paper (if supported)
    commands.addAll([0x1D, 0x56, 0x41, 0x03]); // GS V A n - Partial cut

    return commands;
  }

  /// Check if printer is reachable
  Future<PrinterResult> checkConnection({
    required String ipAddress,
    int port = 9100,
  }) async {
    try {
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return PrinterResult(
        success: true,
        message: 'Printer is reachable',
        code: 0,
      );
    } catch (e) {
      return PrinterResult(
        success: false,
        message: 'Cannot reach printer: $e',
        code: -1,
      );
    }
  }
}
