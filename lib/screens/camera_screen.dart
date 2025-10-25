import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/image_preview_card.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;

  Future<void> _takePhoto() async {
    // Bypass permission check - assume camera is always available
    print('📱 Taking photo with camera (permissions bypassed)');

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _capturedImage = File(pickedFile.path));
    }
  }

  Future<void> _pickFromGallery() async {
    // Bypass permission check - assume photo library is always available
    print('📱 Picking from gallery (permissions bypassed)');

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _capturedImage = File(pickedFile.path));
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
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
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _retakePhoto() {
    setState(() => _capturedImage = null);
  }

  void _usePhoto() {
    if (_capturedImage != null) {
      Navigator.pop(context, _capturedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Take Photo'),
          ],
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _capturedImage != null
                  ? ImagePreviewCard(
                      image: _capturedImage!,
                      onClear: _retakePhoto,
                    )
                  : Card(
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No photo taken',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_capturedImage != null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _retakePhoto,
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _usePhoto,
                      child: const Text('Use Photo'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
} 