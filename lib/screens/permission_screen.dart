import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main_navigation_screen.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  
  const PermissionScreen({super.key, this.onPermissionsGranted});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    try {
      // Simulate permission request delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() => _isRequesting = false);

      // Always proceed to main app (bypass permission checks)
      print('📱 Bypassing permission checks - proceeding to main app');
      
      // Call the callback if provided
      if (widget.onPermissionsGranted != null) {
        widget.onPermissionsGranted!();
      } else {
        // Navigate to main app if no callback provided
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      }
    } catch (e) {
      print('📱 Error in permission flow: $e');
      setState(() => _isRequesting = false);
      
      // Even on error, proceed to main app
      if (widget.onPermissionsGranted != null) {
        widget.onPermissionsGranted!();
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs camera and photo library access to detect plant diseases. '
          'Please enable these permissions in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF047857),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco,
                  size: 60,
                  color: Color(0xFF047857),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Leaf Disease Detector',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Detect plant diseases with AI-powered analysis',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Permission explanation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'This app needs access to:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionItem(
                      Icons.camera_alt,
                      'Camera',
                      'Take photos of plant leaves',
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionItem(
                      Icons.photo_library,
                      'Photo Library',
                      'Select images from your gallery',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Request permissions button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF047857),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isRequesting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF047857)),
                          ),
                        )
                      : const Text(
                          'Enable Permissions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip button
              TextButton(
                onPressed: () {
                  // Always navigate to main app when skipping
                  if (widget.onPermissionsGranted != null) {
                    widget.onPermissionsGranted!();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    );
                  }
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
