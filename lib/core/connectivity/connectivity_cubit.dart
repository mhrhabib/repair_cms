import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityCubit(this._connectivity) : super(const ConnectivityInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(results);
      },
      onError: (error) {
        debugPrint('Connectivity error: $error');
      },
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    // If any connection is available (wifi, mobile, ethernet, etc.)
    final isConnected = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (isConnected) {
      // Network is available, but verify actual internet access
      final hasInternet = await _checkInternetAccess();
      if (hasInternet) {
        debugPrint('Internet connected and verified');
        emit(const ConnectivityOnline());
      } else {
        debugPrint('Network connected but no internet access');
        emit(const ConnectivityOffline());
      }
    } else {
      debugPrint('Network disconnected');
      emit(const ConnectivityOffline());
    }
  }

  /// Verifies actual internet access by attempting to reach reliable hosts
  Future<bool> _checkInternetAccess() async {
    try {
      // Try multiple reliable hosts in case one is down
      final addresses = [
        'google.com',
        'cloudflare.com',
        '1.1.1.1', // Cloudflare DNS
      ];

      for (final address in addresses) {
        try {
          final result = await InternetAddress.lookup(address).timeout(const Duration(seconds: 5));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            debugPrint('Internet access verified via $address');
            return true;
          }
        } catch (e) {
          debugPrint('Failed to reach $address: $e');
          continue;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      emit(const ConnectivityOffline());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
