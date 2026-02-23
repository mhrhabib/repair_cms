// lib/features/printing/services/printer_protocol_detector.dart
import 'dart:async';
import 'dart:io';

class PrinterProtocol {
  final String name;
  final int port;
  final String description;
  final bool isSecure;

  const PrinterProtocol({required this.name, required this.port, required this.description, this.isSecure = false});

  static const rawTcp = PrinterProtocol(name: 'RAW/TCP', port: 9100, description: 'Standard TCP/IP printing');
  static const ipp = PrinterProtocol(name: 'IPP', port: 631, description: 'Internet Printing Protocol');
  static const lpr = PrinterProtocol(name: 'LPR/LPD', port: 515, description: 'Line Printer Daemon');
  static const http = PrinterProtocol(name: 'HTTP', port: 80, description: 'Web interface');
  static const https = PrinterProtocol(name: 'HTTPS', port: 443, description: 'Secure web interface');
  static const ipps = PrinterProtocol(name: 'IPPS', port: 631, description: 'IPP over TLS', isSecure: true);
  static const wsd = PrinterProtocol(name: 'WSD', port: 5357, description: 'Web Services for Devices');
  static const smb = PrinterProtocol(name: 'SMB/CIFS', port: 445, description: 'Windows sharing');

  static const allProtocols = [rawTcp, ipp, lpr, http, https, ipps, wsd, smb];
}

class ProtocolDetectionResult {
  final String ipAddress;
  final List<PrinterProtocol> availableProtocols;
  final PrinterProtocol? recommendedProtocol;
  final String? error;
  final bool isReachable;

  ProtocolDetectionResult({
    required this.ipAddress,
    required this.availableProtocols,
    this.recommendedProtocol,
    this.error,
    required this.isReachable,
  });

  bool get hasProtocols => availableProtocols.isNotEmpty;
}

class PrinterProtocolDetector {
  // static const int _timeoutMs = 2000;
  static const Duration _socketTimeout = Duration(milliseconds: 1500);

  /// Detect all available protocols for a printer IP
  Future<ProtocolDetectionResult> detectProtocols(String ipAddress) async {
    // First, check if the printer is reachable via ping
    final isReachable = await _pingHost(ipAddress);

    if (!isReachable) {
      return ProtocolDetectionResult(
        ipAddress: ipAddress,
        availableProtocols: [],
        isReachable: false,
        error: 'Printer not reachable',
      );
    }

    // Check protocols concurrently
    final results = await Future.wait(
      PrinterProtocol.allProtocols.map((protocol) => _checkProtocol(ipAddress, protocol)),
    );

    final availableProtocols = <PrinterProtocol>[];
    for (int i = 0; i < results.length; i++) {
      if (results[i]) {
        availableProtocols.add(PrinterProtocol.allProtocols[i]);
      }
    }

    // Determine recommended protocol (prioritization logic)
    final recommendedProtocol = _getRecommendedProtocol(availableProtocols);

    return ProtocolDetectionResult(
      ipAddress: ipAddress,
      availableProtocols: availableProtocols,
      recommendedProtocol: recommendedProtocol,
      isReachable: true,
    );
  }

  /// Quick check - test only the most common protocols
  Future<PrinterProtocol?> quickDetect(String ipAddress) async {
    const quickProtocols = [PrinterProtocol.rawTcp, PrinterProtocol.ipp, PrinterProtocol.http];

    for (final protocol in quickProtocols) {
      try {
        final isOpen = await _checkPort(ipAddress, protocol.port);
        if (isOpen) {
          // Additional validation for IPP
          if (protocol.port == 631) {
            final hasIpp = await _verifyIPP(ipAddress);
            if (hasIpp) return protocol;
          } else {
            return protocol;
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Check a specific protocol
  Future<bool> _checkProtocol(String ipAddress, PrinterProtocol protocol) async {
    try {
      final isOpen = await _checkPort(ipAddress, protocol.port);

      if (!isOpen) return false;

      // Additional validation for specific protocols
      switch (protocol.port) {
        case 631:
          return await _verifyIPP(ipAddress);
        case 80:
        case 443:
          return await _verifyWebInterface(ipAddress, protocol.port);
        case 9100:
          return await _verifyRawPort(ipAddress);
        default:
          return true; // Port open is enough for others
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if a port is open
  Future<bool> _checkPort(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: _socketTimeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify IPP service (not just port open)
  Future<bool> _verifyIPP(String ip) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://$ip:631/ipp/print'));
      request.headers.set('Content-Type', 'application/ipp');

      final response = await request.close().timeout(_socketTimeout);
      // IPP should return success or method-not-allowed
      return response.statusCode == 200 || response.statusCode == 405;
    } catch (e) {
      // Try HTTPS
      try {
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('https://$ip:631/ipp/print'));
        request.headers.set('Content-Type', 'application/ipp');

        final response = await request.close().timeout(_socketTimeout);
        return response.statusCode == 200 || response.statusCode == 405;
      } catch (e2) {
        return false;
      }
    }
  }

  /// Verify web interface
  Future<bool> _verifyWebInterface(String ip, int port) async {
    try {
      final protocol = port == 443 ? 'https' : 'http';
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$protocol://$ip:$port/'));

      final response = await request.close().timeout(_socketTimeout);
      // Check for common printer web server headers
      final serverHeader = response.headers.value('server') ?? '';
      return response.statusCode == 200 &&
          (serverHeader.contains('Printer') ||
              serverHeader.contains('HP') ||
              serverHeader.contains('Epson') ||
              serverHeader.contains('Brother') ||
              serverHeader.contains('Canon'));
    } catch (e) {
      return false;
    }
  }

  /// Verify RAW port responds
  Future<bool> _verifyRawPort(String ip) async {
    try {
      final socket = await Socket.connect(ip, 9100, timeout: const Duration(milliseconds: 500));

      // Send a simple ESC command and see if we can write
      socket.add([0x1B, 0x40]); // ESC @
      await socket.flush();
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Ping the host
  Future<bool> _pingHost(String ip) async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('ping', ['-n', '1', '-w', '1000', ip]);
        return result.exitCode == 0;
      } else {
        final result = await Process.run('ping', ['-c', '1', '-W', '1', ip]);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get recommended protocol based on availability
  PrinterProtocol? _getRecommendedProtocol(List<PrinterProtocol> available) {
    // Priority order
    if (available.any((p) => p.port == 631)) return PrinterProtocol.ipp;
    if (available.any((p) => p.port == 9100)) return PrinterProtocol.rawTcp;
    if (available.any((p) => p.port == 515)) return PrinterProtocol.lpr;
    if (available.any((p) => p.port == 80 || p.port == 443)) {
      final httpProto = available.firstWhere((p) => p.port == 80 || p.port == 443);
      return httpProto;
    }
    return available.isNotEmpty ? available.first : null;
  }

  /// Get protocol description for UI
  static String getProtocolDescription(PrinterProtocol protocol) {
    switch (protocol.port) {
      case 9100:
        return 'Raw TCP port (9100) - Most compatible with older printers';
      case 631:
        return 'IPP (Internet Printing Protocol) - Recommended for modern printers';
      case 515:
        return 'LPR/LPD - Common in corporate/Unix environments';
      case 80:
        return 'HTTP Web Interface - Can use IPP over HTTP';
      case 443:
        return 'HTTPS Web Interface - Secure web access';
      case 5357:
        return 'WSD (Web Services for Devices) - Windows network discovery';
      case 445:
        return 'SMB/CIFS - Windows shared printer';
      default:
        return 'Port ${protocol.port}';
    }
  }
}
