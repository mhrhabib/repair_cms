import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../../../core/constants/app_colors.dart';

/// Model for discovered printer
class DiscoveredPrinter {
  final String ipAddress;
  final int port;
  final bool isReachable;
  final String? hostname;

  DiscoveredPrinter({required this.ipAddress, required this.port, required this.isReachable, this.hostname});
}

/// WiFi Printer Scanner Widget
class WiFiPrinterScanner extends StatefulWidget {
  final Function(String ipAddress, int port) onPrinterSelected;
  final List<int> portsToScan;

  const WiFiPrinterScanner({
    super.key,
    required this.onPrinterSelected,
    this.portsToScan = const [9100, 9101, 9102, 515, 631],
  });

  @override
  State<WiFiPrinterScanner> createState() => _WiFiPrinterScannerState();
}

class _WiFiPrinterScannerState extends State<WiFiPrinterScanner> {
  final NetworkInfo _networkInfo = NetworkInfo();
  bool _isScanning = false;
  double _scanProgress = 0.0;
  String _scanStatus = 'Ready to scan';
  List<DiscoveredPrinter> _discoveredPrinters = [];

  /// Get local IP address
  Future<String?> _getLocalIp() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      return wifiIP;
    } catch (e) {
      debugPrint('❌ Error getting local IP: $e');
      return null;
    }
  }

  /// Scan network for printers
  Future<void> _scanNetwork() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
      _scanStatus = 'Getting network information...';
      _discoveredPrinters.clear();
    });

    try {
      // Get local IP
      final localIp = await _getLocalIp();
      if (localIp == null) {
        setState(() {
          _scanStatus = 'Unable to get network information';
          _isScanning = false;
        });
        return;
      }

      debugPrint('📡 Local IP: $localIp');

      // Extract network prefix (e.g., "192.168.1" from "192.168.1.100")
      final ipParts = localIp.split('.');
      if (ipParts.length != 4) {
        setState(() {
          _scanStatus = 'Invalid IP format';
          _isScanning = false;
        });
        return;
      }

      final networkPrefix = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';
      debugPrint('🌐 Scanning network: $networkPrefix.x');

      setState(() {
        _scanStatus = 'Scanning $networkPrefix.x ...';
      });

      // Scan IP range (1-254)
      final int totalHosts = 254;
      int scannedHosts = 0;

      for (int i = 1; i <= 254; i++) {
        if (!_isScanning) break; // Allow cancellation

        final ip = '$networkPrefix.$i';

        // Update progress
        scannedHosts++;
        setState(() {
          _scanProgress = scannedHosts / totalHosts;
          _scanStatus = 'Scanning $ip ... (${scannedHosts}/$totalHosts)';
        });

        // Check each port for this IP
        for (int port in widget.portsToScan) {
          final isReachable = await _checkPort(ip, port);
          if (isReachable) {
            final printer = DiscoveredPrinter(ipAddress: ip, port: port, isReachable: true);

            setState(() {
              _discoveredPrinters.add(printer);
            });

            debugPrint('✅ Found printer at $ip:$port');
          }
        }
      }

      setState(() {
        _isScanning = false;
        _scanProgress = 1.0;
        _scanStatus = 'Scan complete. Found ${_discoveredPrinters.length} printer(s)';
      });
    } catch (e) {
      debugPrint('❌ Scan error: $e');
      setState(() {
        _isScanning = false;
        _scanStatus = 'Scan failed: $e';
      });
    }
  }

  /// Check if a port is open on given IP
  Future<bool> _checkPort(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 500));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cancel ongoing scan
  void _cancelScan() {
    setState(() {
      _isScanning = false;
      _scanStatus = 'Scan cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(maxHeight: 600.h, maxWidth: 500.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.wifi_find, color: AppColors.primary, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Discover WiFi Printers',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: 16.h),

            // Info text
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This will scan your local network for printers on common ports (9100, 9101, 515, 631)',
                      style: TextStyle(fontSize: 12.sp, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Scan button or progress
            if (!_isScanning)
              ElevatedButton.icon(
                onPressed: _scanNetwork,
                icon: const Icon(Icons.search),
                label: const Text('Start Scanning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              )
            else
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _scanProgress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    _scanStatus,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 12.h),
                  TextButton.icon(
                    onPressed: _cancelScan,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Scan'),
                  ),
                ],
              ),

            SizedBox(height: 20.h),

            // Discovered printers list
            if (_discoveredPrinters.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Discovered Printers (${_discoveredPrinters.length})',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12.h),
            ],

            Flexible(
              child: _discoveredPrinters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print_disabled, size: 64.sp, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          Text(
                            'No printers found yet',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Click "Start Scanning" to search',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _discoveredPrinters.length,
                      itemBuilder: (context, index) {
                        final printer = _discoveredPrinters[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.print, color: Colors.green.shade700, size: 24.sp),
                            ),
                            title: Text(
                              printer.ipAddress,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
                            ),
                            subtitle: Text(
                              'Port: ${printer.port}',
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                widget.onPrinterSelected(printer.ipAddress, printer.port);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              ),
                              child: const Text('Use'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isScanning = false;
    super.dispose();
  }
}
