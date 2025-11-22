import 'dart:async';
import 'dart:io';
import 'dart:math';
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
  final List<DiscoveredPrinter> _discoveredPrinters = [];

  // Performance optimizations
  static const int _maxConcurrentScans = 50; // Scan up to 50 IPs concurrently
  static const int _socketTimeoutMs = 150; // Reduced from 500ms to 150ms
  static const int _batchSize = 10; // Process IPs in batches of 10
  static const Duration _scanTimeout = Duration(seconds: 30); // Max scan time

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

  /// Scan network for printers (optimized concurrent version)
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

      // Create prioritized list of IPs to scan (common addresses first)
      final prioritizedIps = _createPrioritizedIpList(networkPrefix);

      // Scan with timeout
      await _scanInConcurrentBatches(prioritizedIps).timeout(
        _scanTimeout,
        onTimeout: () {
          debugPrint('⏰ Scan timed out after ${_scanTimeout.inSeconds} seconds');
        },
      );

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

  /// Scan IPs in concurrent batches for maximum speed
  Future<void> _scanInConcurrentBatches(List<String> allIps) async {
    final totalHosts = allIps.length;
    int scannedHosts = 0;
    final semaphore = _Semaphore(_maxConcurrentScans); // Limit concurrent operations

    // Process IPs in batches
    for (int batchStart = 0; batchStart < totalHosts; batchStart += _batchSize) {
      if (!_isScanning) break; // Allow cancellation

      final batchEnd = min(batchStart + _batchSize, totalHosts);
      final batchIps = allIps.sublist(batchStart, batchEnd);

      // Scan this batch concurrently
      final batchFutures = batchIps.map((ip) => _scanSingleIpConcurrent(ip, semaphore));

      // Wait for all IPs in this batch to complete
      await Future.wait(batchFutures);

      // Update progress
      scannedHosts += batchIps.length;
      setState(() {
        _scanProgress = scannedHosts / totalHosts;
        _scanStatus = 'Scanning... $scannedHosts/$totalHosts IPs ($_discoveredPrinters.length printers found)';
      });
    }
  }

  /// Scan a single IP address for all ports concurrently
  Future<void> _scanSingleIpConcurrent(String ip, _Semaphore semaphore) async {
    await semaphore.acquire();

    try {
      // Check all ports for this IP concurrently
      final portFutures = widget.portsToScan.map((port) => _checkPortFast(ip, port));

      // Wait for all port checks to complete
      final results = await Future.wait(portFutures);

      // Add any discovered printers
      for (int i = 0; i < results.length; i++) {
        if (results[i] && _isScanning) {
          final printer = DiscoveredPrinter(ipAddress: ip, port: widget.portsToScan[i], isReachable: true);

          if (mounted) {
            setState(() {
              _discoveredPrinters.add(printer);
            });
          }

          debugPrint('✅ Found printer at $ip:${widget.portsToScan[i]}');
        }
      }
    } finally {
      semaphore.release();
    }
  }

  /// Create prioritized list of IPs (common addresses first for faster discovery)
  List<String> _createPrioritizedIpList(String networkPrefix) {
    final commonIps = <String>[];
    final otherIps = <String>[];

    // Common IP addresses that often have printers/network devices
    final priorityAddresses = [1, 10, 20, 50, 100, 150, 200, 254];

    for (int i = 1; i <= 254; i++) {
      final ip = '$networkPrefix.$i';
      if (priorityAddresses.contains(i)) {
        commonIps.add(ip);
      } else {
        otherIps.add(ip);
      }
    }

    // Return common IPs first, then the rest
    return [...commonIps, ...otherIps];
  }

  /// Check if a port is open on given IP (optimized with shorter timeout)
  Future<bool> _checkPortFast(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: _socketTimeoutMs));
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

/// Simple semaphore implementation for limiting concurrent operations
class _Semaphore {
  final int _maxCount;
  int _currentCount = 0;
  final List<Completer<void>> _waitQueue = [];

  _Semaphore(this._maxCount);

  Future<void> acquire() async {
    if (_currentCount < _maxCount) {
      _currentCount++;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    await completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeAt(0);
      completer.complete();
    } else {
      _currentCount = max(0, _currentCount - 1);
    }
  }
}
