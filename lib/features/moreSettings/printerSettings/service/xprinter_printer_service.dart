import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/set_up_di.dart';

import 'base_printer_service.dart';
import '../models/printer_config_model.dart';

/// Xprinter thermal printer service
/// Supports XP-420B, XP-470B, XP-DT425B and other ESC/POS compatible Xprinter models
class XprinterPrinterService implements BasePrinterService {
  static final XprinterPrinterService _instance =
      XprinterPrinterService._internal();
  factory XprinterPrinterService() => _instance;
  XprinterPrinterService._internal();

  Talker get _talker => SetUpDI.getIt<Talker>();

  @override
  Future<PrinterResult> printThermalReceipt({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // For Xprinter label printers, "receipts" are often printed as labels using TSPL
    return printLabel(
      ipAddress: ipAddress,
      text: text,
      port: port,
      timeout: timeout,
    );
  }

  @override
  Future<PrinterResult> printLabel({
    required String ipAddress,
    required String text,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
    LabelSize? labelSize,
  }) async {
    try {
      _talker.info('[TSPL: $ipAddress] Starting Xprinter TSPL label print');
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      final width = labelSize?.width ?? 50;
      final height = labelSize?.height ?? 25;

      final List<int> commands = [];
      // TSPL Initialize
      commands.addAll(utf8.encode('SIZE $width mm,$height mm\r\n'));
      commands.addAll(utf8.encode('GAP 3 mm,0 mm\r\n'));
      commands.addAll(utf8.encode('DIRECTION 1\r\n'));
      commands.addAll(utf8.encode('CLS\r\n'));

      // Print text
      // We'll split the text into lines and print each
      final lines = text.split('\n');
      int y = 10;
      for (final line in lines) {
        if (line.trim().isEmpty) {
          y += 24;
          continue;
        }
        // TEXT x,y,"font",rotation,x-multi,y-multi,"content"
        commands.addAll(utf8.encode('TEXT 10,$y,"3",0,1,1,"$line"\r\n'));
        y += 30;
      }

      commands.addAll(utf8.encode('PRINT 1,1\r\n'));

      socket.add(Uint8List.fromList(commands));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500));
      await socket.close();

      return PrinterResult(
        success: true,
        message: 'Xprinter TSPL label printed',
        code: 0,
      );
    } catch (e) {
      _talker.error('[TSPL: $ipAddress] ❌ TSPL print error: $e');
      return PrinterResult(success: false, message: 'TSPL Error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printDeviceLabel({
    required String ipAddress,
    required Map<String, String> labelData,
    int port = 9100,
    Duration timeout = const Duration(seconds: 5),
    LabelSize? labelSize,
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: timeout);

      final width = labelSize?.width ?? 50;
      final height = labelSize?.height ?? 25;

      final List<int> bytes = [];

      // TSPL Header
      bytes.addAll(utf8.encode('SIZE $width mm,$height mm\r\n'));
      bytes.addAll(utf8.encode('GAP 3 mm,0 mm\r\n'));
      bytes.addAll(utf8.encode('DIRECTION 1\r\n'));
      bytes.addAll(utf8.encode('CLS\r\n'));

      // Header - Brand/Job
      bytes.addAll(
        utf8.encode(
          'TEXT 10,10,"4",0,1,1,"JOB: ${labelData['jobNumber'] ?? 'N/A'}"\r\n',
        ),
      );

      // Details
      bytes.addAll(
        utf8.encode(
          'TEXT 10,60,"3",0,1,1,"Cust: ${labelData['customerName'] ?? 'N/A'}"\r\n',
        ),
      );
      bytes.addAll(
        utf8.encode(
          'TEXT 10,100,"3",0,1,1,"Dev: ${labelData['deviceName'] ?? 'N/A'}"\r\n',
        ),
      );
      bytes.addAll(
        utf8.encode(
          'TEXT 10,140,"3",0,1,1,"IMEI: ${labelData['imei'] ?? 'N/A'}"\r\n',
        ),
      );

      // Barcode (if supported by Xprinter TSPL)
      final jobNo = labelData['jobNumber'] ?? '';
      if (jobNo.isNotEmpty) {
        // BARCODE x,y,"type",height,human-readable,rotation,narrow,wide,"content"
        bytes.addAll(
          utf8.encode('BARCODE 10,180,"128",60,1,0,2,2,"$jobNo"\r\n'),
        );
      }

      bytes.addAll(utf8.encode('PRINT 1,1\r\n'));

      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await socket.close();

      return PrinterResult(
        success: true,
        message: 'TSPL Device Label printed',
        code: 0,
      );
    } catch (e) {
      return PrinterResult(success: false, message: 'TSPL Error: $e', code: -1);
    }
  }

  @override
  Future<PrinterResult> printLabelImage({
    required String ipAddress,
    required Uint8List imageBytes,
    int port = 9100,
    LabelSize? labelSize,
  }) async {
    try {
      _talker.info('[TSPL-Image: $ipAddress] Starting bitmap print');
      debugPrint(
        '🖨️ [XprinterImage: $ipAddress] Image data: ${imageBytes.length} bytes',
      );

      final widthMm = labelSize?.width ?? 50;
      final heightMm = labelSize?.height ?? 25;

      // 1. Decode and process image
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      _talker.debug(
        '✅ Decoded image: ${uiImage.width}x${uiImage.height} pixels',
      );

      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) throw Exception('Image data error');

      final imgLib = img.Image.fromBytes(
        width: uiImage.width,
        height: uiImage.height,
        bytes: byteData.buffer,
        numChannels: 4,
      );

      // Convert to grayscale for monochrome thermal printing
      final bwImg = img.grayscale(imgLib);
      debugPrint(
        '📐 [XprinterImage] Processed: ${bwImg.width}x${bwImg.height} pixels (B&W)',
      );

      // 2. Build TSPL Bitmap commands
      final commands = <int>[];
      // Initialize
      commands.addAll(utf8.encode('SIZE $widthMm mm,$heightMm mm\r\n'));
      commands.addAll(utf8.encode('GAP 3 mm,0 mm\r\n'));
      commands.addAll(utf8.encode('DIRECTION 1\r\n'));
      commands.addAll(utf8.encode('CLS\r\n'));

      // BITMAP x,y,width_bytes,height,mode,data
      final imgWidth = bwImg.width;
      final imgHeight = bwImg.height;
      final bytesPerRow = (imgWidth + 7) ~/ 8;

      commands.addAll(utf8.encode('BITMAP 0,0,$bytesPerRow,$imgHeight,0,'));

      // Image data (bit-inverted: 0 for white, 1 for black in TSPL)
      for (int y = 0; y < imgHeight; y++) {
        for (int x = 0; x < bytesPerRow * 8; x += 8) {
          int byte = 0;
          for (int bit = 0; bit < 8; bit++) {
            final px = x + bit;
            if (px < imgWidth) {
              final pixel = bwImg.getPixel(px, y);
              // In TSPL, BITMAP mode 0: 1=black, 0=white
              // Luminance < 128 means it's a dark pixel, so set the bit (1 for black)
              if (img.getLuminance(pixel) < 128) {
                byte |= (0x80 >> bit);
              }
            }
          }
          commands.add(byte);
        }
      }
      commands.addAll(utf8.encode('\r\n'));
      commands.addAll(utf8.encode('PRINT 1,1\r\n'));

      // 3. Send to printer
      final socket = await Socket.connect(ipAddress, port);
      debugPrint(
        '🌐 [XprinterImage] Connected to $ipAddress:$port, sending ${commands.length} bytes',
      );
      socket.add(commands);
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1000));
      await socket.close();

      _talker.info(
        '✅ [XprinterImage: $ipAddress] Label image printed successfully',
      );
      return PrinterResult(
        success: true,
        message: 'TSPL Image printed',
        code: 0,
      );
    } catch (e, st) {
      debugPrint('❌ [TSPL-Image: $ipAddress] Error: $e');
      debugPrint('Stack trace: $st');
      _talker.error('[TSPL-Image] Error: $e');
      return PrinterResult(
        success: false,
        message: 'TSPL Image Error: $e',
        code: -1,
      );
    }
  }

  @override
  Future<PrinterStatus> getPrinterStatus({
    required String ipAddress,
    int port = 9100,
  }) async {
    try {
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 4),
      );
      socket.destroy();
      return PrinterStatus(
        isConnected: true,
        message: 'Xprinter printer reachable',
        code: 0,
      );
    } catch (e) {
      return PrinterStatus(
        isConnected: false,
        message: 'Xprinter printer not reachable: $e',
        code: -1,
      );
    }
  }
}
