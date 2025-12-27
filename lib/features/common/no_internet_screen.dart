import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:repair_cms/core/app_exports.dart';

/// A simple full-screen "No Internet" UI.
///
/// - `assetPath` defaults to `assets/lottie/no_internet.json` (add your file there).
/// - `onRetry` can be provided to override the default connectivity check behavior.
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key, this.assetPath = 'assets/lottie/no_internet.json', this.onRetry});

  final String assetPath;
  final VoidCallback? onRetry;

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _loading = false;

  Future<void> _handleRetry() async {
    setState(() => _loading = true);

    try {
      if (widget.onRetry != null) {
        widget.onRetry!();
      } else {
        final result = await Connectivity().checkConnectivity();
        if (result != ConnectivityResult.none) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Still offline')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleExit() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exit not supported on iOS')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie animation (place your json at assets/lottie/no_internet.json)
                SizedBox(
                  height: 260,
                  child: LottieBuilder.asset(
                    widget.assetPath,
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (context, error, stack) =>
                        Icon(Icons.wifi_off, size: 96, color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text('No internet connection', style: AppTypography.fontSize20.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection and try again.',
                  style: AppTypography.sfProText15.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _handleRetry,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (Platform.isAndroid)
                      OutlinedButton.icon(
                        onPressed: _handleExit,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Exit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
