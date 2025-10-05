import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class Error404Screen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String? buttonText;

  const Error404Screen({super.key, required this.errorMessage, this.onRetry, this.buttonText = 'Try Again'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animations/404-error.json', // You'll need to add this file to your assets
                width: 300,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if Lottie file is not found
                  return _buildFallbackAnimation();
                },
              ),

              const SizedBox(height: 32),

              // Error Title
              Text(
                _getErrorTitle(errorMessage),
                style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error Message
              Text(
                _getErrorMessage(errorMessage),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Go Back Button
                  OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.blue.shade400),
                    ),
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade400),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Retry Button
                  if (onRetry != null)
                    ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonText!,
                        style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Additional Help Text for 404
              if (errorMessage.contains('404'))
                Text(
                  'The resource you\'re looking for might have been moved or doesn\'t exist.',
                  style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorTitle(String message) {
    if (message.contains('404')) {
      return 'Page Not Found';
    } else if (message.contains('401') || message.contains('403')) {
      return 'Access Denied';
    } else if (message.contains('500')) {
      return 'Server Error';
    } else if (message.contains('timeout') || message.contains('network')) {
      return 'Connection Error';
    } else {
      return 'Something Went Wrong';
    }
  }

  String _getErrorMessage(String message) {
    if (message.contains('404')) {
      return 'We couldn\'t find the page or resource you\'re looking for. This might be a temporary issue or the page may have been moved.';
    } else if (message.contains('401') || message.contains('403')) {
      return 'You don\'t have permission to access this resource. Please check your credentials and try again.';
    } else if (message.contains('500')) {
      return 'Our servers are experiencing some technical difficulties. Please try again in a few moments.';
    } else if (message.contains('timeout') || message.contains('network')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  Widget _buildFallbackAnimation() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(150)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '404',
            style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// Alternative: Network-based Lottie animation
class NetworkErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const NetworkErrorScreen({super.key, required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Network Lottie Animation
              Lottie.network(
                'https://assets1.lottiefiles.com/packages/lf20_ghfpce1h.json', // 404 animation
                width: 280,
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAnimation();
                },
              ),

              const SizedBox(height: 32),

              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                errorMessage,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 40),

              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAnimation() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
      child: const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
    );
  }
}
