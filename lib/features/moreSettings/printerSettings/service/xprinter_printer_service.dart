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
      commands.addAll(utf8.encode('SIZE $width mm,$height mm\n'));
      commands.addAll(utf8.encode('GAP 3 mm,0 mm\n'));
      commands.addAll(utf8.encode('DIRECTION 1\n'));
      commands.addAll(utf8.encode('SET TEAR ON\n'));
      commands.addAll(utf8.encode('CLS\n'));

      // Print text
      final lines = text.split('\n');
      int y = 10;
      for (final line in lines) {
        final content = line.trim();
        if (content.isEmpty) {
          y += 24;
          continue;
        }
        final escapedText = _escapeTsplString(content);
        // TEXT x,y,"font",rotation,x-multi,y-multi,"content"
        commands.addAll(utf8.encode('TEXT 10,$y,"3",0,1,1,"$escapedText"\n'));
        y += 30;
      }

      commands.addAll(utf8.encode('PRINT 1,1\n'));
      commands.addAll(utf8.encode('EOP\n'));

      socket.add(Uint8List.fromList(commands));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1000));
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

  String _escapeTsplString(String text) {
    // Escape double quotes for TSPL TEXT command
    return text.replaceAll('"', '\\"');
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
      bytes.addAll(utf8.encode('SIZE $width mm,$height mm\n'));
      bytes.addAll(utf8.encode('GAP 3 mm,0 mm\n'));
      bytes.addAll(utf8.encode('DIRECTION 1\n'));
      bytes.addAll(utf8.encode('SET TEAR ON\n'));
      bytes.addAll(utf8.encode('CLS\n'));

      // Header - Brand/Job
      final jobNo = _escapeTsplString(labelData['jobNumber'] ?? 'N/A');
      bytes.addAll(utf8.encode('TEXT 10,10,"4",0,1,1,"JOB: $jobNo"\n'));

      // Details
      bytes.addAll(
        utf8.encode(
          'TEXT 10,60,"3",0,1,1,"Cust: ${_escapeTsplString(labelData['customerName'] ?? 'N/A')}"\n',
        ),
      );
      bytes.addAll(
        utf8.encode(
          'TEXT 10,100,"3",0,1,1,"Dev: ${_escapeTsplString(labelData['deviceName'] ?? 'N/A')}"\n',
        ),
      );
      bytes.addAll(
        utf8.encode(
          'TEXT 10,140,"3",0,1,1,"IMEI: ${_escapeTsplString(labelData['imei'] ?? 'N/A')}"\n',
        ),
      );

      // Barcode
      final jobNoRaw = labelData['jobNumber'] ?? '';
      if (jobNoRaw.isNotEmpty) {
        // BARCODE x,y,"type",height,human-readable,rotation,narrow,wide,"content"
        bytes.addAll(
          utf8.encode('BARCODE 10,180,"128",60,1,0,2,2,"$jobNoRaw"\n'),
        );
      }

      bytes.addAll(utf8.encode('PRINT 1,1\n'));
      bytes.addAll(utf8.encode('EOP\n'));

      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1000));
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
      // DIRECTION 1: printer outputs label in orientation user prefers.
      // The user confirmed that the border test (which uses DIRECTION 1)
      // prints correctly, while DIRECTION 0 was making the bitmap
      // print upside down and reversed.
      commands.addAll(utf8.encode('SIZE $widthMm mm,$heightMm mm\n'));
      commands.addAll(utf8.encode('GAP 3 mm,0 mm\n'));
      commands.addAll(utf8.encode('DIRECTION 1\n'));
      commands.addAll(utf8.encode('SET TEAR ON\n'));
      commands.addAll(utf8.encode('CLS\n'));

      // BITMAP x,y,width_bytes,height,mode,data
      final imgWidth = bwImg.width;
      final imgHeight = bwImg.height;
      final bytesPerRow = (imgWidth + 7) ~/ 8;

      commands.addAll(utf8.encode('BITMAP 0,0,$bytesPerRow,$imgHeight,0,'));

      // Bit polarity: 0=black dot (ink), 1=white (no ink) for this Xprinter.
      // Set bit for LIGHT (white) pixels so the background is un-inked.
      for (int y = 0; y < imgHeight; y++) {
        for (int x = 0; x < bytesPerRow * 8; x += 8) {
          int byte = 0;
          for (int bit = 0; bit < 8; bit++) {
            final px = x + bit;
            if (px < imgWidth) {
              final pixel = bwImg.getPixel(px, y);
              // Set bit for LIGHT (white) pixels → 1 = no ink on this printer
              if (img.getLuminance(pixel) >= 128) {
                byte |= (0x80 >> bit);
              }
            }
          }
          commands.add(byte);
        }
      }
      commands.addAll(utf8.encode('\n'));
      commands.addAll(utf8.encode('PRINT 1,1\n'));
      commands.addAll(utf8.encode('EOP\n'));

      // 3. Send to printer
      final socket = await Socket.connect(ipAddress, port);
      debugPrint(
        '🌐 [XprinterImage] Connected to $ipAddress:$port, sending ${commands.length} bytes',
      );
      socket.add(commands);
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1500));
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

  @override
  Future<PrinterResult> printBorderTest({
    required String ipAddress,
    int port = 9100,
    LabelSize? labelSize,
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port);
      final width = labelSize?.width ?? 50;
      final height = labelSize?.height ?? 25;

      final List<int> commands = [];
      commands.addAll(utf8.encode('SIZE $width mm,$height mm\n'));
      commands.addAll(utf8.encode('GAP 3 mm,0 mm\n'));
      commands.addAll(utf8.encode('DIRECTION 1\n'));
      commands.addAll(utf8.encode('CLS\n'));
      // BOX x,y,x_end,y_end,thickness
      final wDots = (width * 8).toInt();
      final hDots = (height * 8).toInt();
      commands.addAll(utf8.encode('BOX 10,10,${wDots - 10},${hDots - 10},4\n'));
      commands.addAll(utf8.encode('TEXT 20,40,"3",0,1,1,"BORDER TEST"\n'));
      commands.addAll(
        utf8.encode('TEXT 20,80,"2",0,1,1,"Size: ${width}x${height}mm"\n'),
      );
      commands.addAll(utf8.encode('PRINT 1,1\n'));
      commands.addAll(utf8.encode('EOP\n'));

      socket.add(Uint8List.fromList(commands));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 1000));
      await socket.close();

      return PrinterResult(success: true, message: 'Border test sent', code: 0);
    } catch (e) {
      return PrinterResult(
        success: false,
        message: 'Test failed: $e',
        code: -1,
      );
    }
  }

  @override
  Future<PrinterResult> calibrate({
    required String ipAddress,
    int port = 9100,
  }) async {
    try {
      final socket = await Socket.connect(ipAddress, port);
      socket.add(utf8.encode('AUTODETECT\n'));
      await socket.flush();
      await socket.close();
      return PrinterResult(success: true, message: 'Calibration sent', code: 0);
    } catch (e) {
      return PrinterResult(
        success: false,
        message: 'Calibration failed: $e',
        code: -1,
      );
    }
  }
}
