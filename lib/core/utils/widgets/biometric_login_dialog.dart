import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/services/biometric_service.dart';

class BiometricLoginDialog extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final VoidCallback onUsePassword;

  const BiometricLoginDialog({super.key, required this.onBiometricSuccess, required this.onUsePassword});

  @override
  State<BiometricLoginDialog> createState() => _BiometricLoginDialogState();
}

class _BiometricLoginDialogState extends State<BiometricLoginDialog> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _biometricType = 'Biometric';
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAndAuthenticate(); // Auto-trigger authentication
  }

  Future<void> _initializeAndAuthenticate() async {
    try {
      // Get biometric type
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      if (mounted) {
        setState(() {
          _biometricType = _biometricService.getBiometricTypeName(availableBiometrics);
        });
      }

      // Small delay for UI to render
      await Future.delayed(const Duration(milliseconds: 300));

      // Auto-trigger authentication
      if (mounted) {
        _authenticate();
      }
    } catch (e) {
      debugPrint('Error initializing biometric: $e');
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = _biometricType.contains('Face') ? 'Look at the camera...' : 'Touch the sensor...';
    });

    try {
      final isAuthenticated = await _biometricService.authenticate(reason: 'Verify it\'s you to login to your account');

      if (!mounted) return;

      setState(() {
        _isAuthenticating = false;
      });

      if (isAuthenticated) {
        setState(() {
          _statusMessage = 'Authentication successful!';
        });
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
          widget.onBiometricSuccess();
        }
      } else {
        setState(() {
          _statusMessage = 'Authentication failed or canceled';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _statusMessage = 'Authentication error: ${e.toString()}';
      });
      debugPrint('Authentication error: $e');
    }
  }

  void _onUsePassword() {
    if (!_isAuthenticating && mounted) {
      Navigator.pop(context);
      widget.onUsePassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, obj) async {
        // Prevent pop while authenticating by doing nothing; this function returns void.
        if (_isAuthenticating) {
          return;
        }
        // Otherwise allow the pop to proceed (no explicit return required).
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _statusMessage.contains('successful')
                    ? Icons.check_circle
                    : _biometricType.contains('Face')
                    ? Icons.face
                    : Icons.fingerprint,
                key: ValueKey(_statusMessage.contains('successful')),
                size: 60,
                color: _statusMessage.contains('successful') ? Colors.green : AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage.contains('successful') ? 'Success!' : 'Verify It\'s You',
              style: AppTypography.sfProHeadLineTextStyle28.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_statusMessage.contains('successful'))
              Text(
                'Use your $_biometricType to verify your identity',
                style: AppTypography.sfProText15,
                textAlign: TextAlign.center,
              ),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isAuthenticating)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      _statusMessage,
                      style: AppTypography.sfProText15.copyWith(
                        color: _statusMessage.contains('successful')
                            ? Colors.green
                            : _statusMessage.contains('failed')
                            ? Colors.orange
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (!_isAuthenticating) ...[
            TextButton(
              onPressed: _onUsePassword,
              child: Text('Use Password', style: AppTypography.sfProText15.copyWith(color: AppColors.primary)),
            ),
          ],
          if (!_isAuthenticating && _statusMessage.contains('failed'))
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Try Again', style: AppTypography.sfProText15.copyWith(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
