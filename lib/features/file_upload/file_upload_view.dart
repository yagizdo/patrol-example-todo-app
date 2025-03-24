import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen>
    with WidgetsBindingObserver {
  String? _fileName;
  String? _filePath;
  bool _isLoading = false;
  File? _imageFile;
  String? _imageSource;
  String? _errorMessage;
  bool _hasPermissionError = false;
  Permission? _deniedPermission;
  ImageSource? _lastImageSource;
  bool _returnedFromSettings = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Register this object as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister this object as an observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log('App lifecycle state changed to: $state',
        name: 'permissions');

    // When the app is resumed (e.g., after returning from settings)
    if (state == AppLifecycleState.resumed && _returnedFromSettings) {
      _returnedFromSettings = false;

      // If we have a denied permission, retry the operation
      if (_deniedPermission != null && _lastImageSource != null) {
        // Use a small delay to ensure the app is fully resumed
        Timer(const Duration(milliseconds: 500), () {
          _retryAfterSettings();
        });
      }
    }

    // When the app is resumed after being inactive (e.g., after camera/gallery)
    if (state == AppLifecycleState.resumed && _isLoading) {
      developer.log(
          'App resumed while loading, likely camera/gallery was canceled',
          name: 'permissions');

      // Use a small delay to ensure the app is fully resumed
      Timer(const Duration(milliseconds: 500), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  // Helper method to retry after returning from settings
  Future<void> _retryAfterSettings() async {
    if (_lastImageSource != null) {
      // Clear error state
      setState(() {
        _errorMessage = null;
        _hasPermissionError = false;
      });

      // Try again with the same source
      await _pickImage(_lastImageSource!);
    }
  }

  // Helper method to open app settings
  Future<void> _openAppSettings() async {
    _returnedFromSettings = true;

    if (Platform.isIOS) {
      // On iOS, open the app's settings page directly
      developer.log('Opening iOS app settings', name: 'permissions');
      await AppSettings.openAppSettings();
    } else {
      // On Android and other platforms, open the general app settings
      developer.log('Opening general app settings', name: 'permissions');
      await AppSettings.openAppSettings();
    }
  }

  // Helper method to get platform-specific instructions
  String _getPlatformSpecificInstructions() {
    if (Platform.isIOS) {
      return 'To enable access:\n1. Open the Settings app\n2. Scroll down and tap on this app\n3. Enable Camera and Photos access';
    } else if (Platform.isAndroid) {
      return 'Go to Settings > Apps > This App > Permissions and enable the required permissions.';
    } else {
      return 'Please enable the required permissions in your device settings.';
    }
  }

  // Helper method to check camera permission
  Future<bool> _checkCameraPermission() async {
    // Log for debugging
    developer.log('Checking camera permission on ${Platform.operatingSystem}',
        name: 'permissions');

    if (Platform.isIOS) {
      // On iOS, we need to handle permissions differently
      try {
        // Try to access the camera directly, which will trigger the permission dialog
        developer.log('iOS: Attempting to access camera directly',
            name: 'permissions');

        final XFile? testImage = await _picker
            .pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
        )
            .catchError((error) {
          // Handle any errors during permission check
          developer.log('Error during camera permission check: $error',
              name: 'permissions');

          // Check if the error is permission-related
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('permission') ||
              errorStr.contains('denied') ||
              errorStr.contains('access')) {
            setState(() {
              _hasPermissionError = true;
              _deniedPermission = Permission.camera;
              _errorMessage =
                  'Camera access was denied. ${_getPlatformSpecificInstructions()}';
            });
          } else {
            setState(() {
              _errorMessage = 'Error accessing camera: $error';
            });
          }
          return null; // Return null to indicate error
        });

        // If we got an image, permission was granted
        if (testImage != null) {
          developer.log('iOS: Camera permission granted (got test image)',
              name: 'permissions');
          // Delete the test image if needed
          await File(testImage.path).delete().catchError((e) => null);
          return true;
        }

        // If we reach here, user likely canceled the camera but permission is granted
        developer.log(
            'iOS: User canceled camera but permission might be granted',
            name: 'permissions');
        return true;
      } catch (e) {
        // Check if the error is permission-related
        developer.log('iOS: Camera access error: $e', name: 'permissions');
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('permission') ||
            errorStr.contains('denied') ||
            errorStr.contains('access')) {
          setState(() {
            _hasPermissionError = true;
            _deniedPermission = Permission.camera;
            _errorMessage =
                'Camera access was denied. ${_getPlatformSpecificInstructions()}';
          });
          return false;
        }

        // For other errors, just return false
        setState(() {
          _errorMessage = 'Error accessing camera: $e';
        });
        return false;
      }
    } else {
      // For Android and other platforms, use the permission_handler approach
      // First check the current status
      final status = await Permission.camera.status;

      // Log the initial status for debugging
      developer.log('Camera permission initial status: $status',
          name: 'permissions');

      // If permission is already granted, return true
      if (status.isGranted) {
        developer.log('Camera permission already granted', name: 'permissions');
        return true;
      }

      // For fresh installs or when permission hasn't been requested yet,
      // status.isDenied will be true, but we should still show the system dialog
      // Request the permission - this will show the system dialog
      developer.log('Requesting camera permission...', name: 'permissions');
      final result = await Permission.camera.request();
      developer.log('Camera permission request result: $result',
          name: 'permissions');

      // After request, check the new status
      if (result.isGranted) {
        developer.log('Camera permission granted after request',
            name: 'permissions');
        return true;
      } else if (result.isPermanentlyDenied) {
        // User permanently denied (clicked "Don't ask again" or similar)
        developer.log('Camera permission permanently denied',
            name: 'permissions');
        setState(() {
          _hasPermissionError = true;
          _deniedPermission = Permission.camera;
          _errorMessage = _getPermissionErrorMessage('Camera', true);
        });
        return false;
      } else if (result.isDenied) {
        // User denied but not permanently (clicked "Deny")
        developer.log('Camera permission denied (not permanently)',
            name: 'permissions');
        setState(() {
          _hasPermissionError = true;
          _deniedPermission = Permission.camera;
          _errorMessage =
              'Camera permission was denied. You can try again or enable it in settings.';
        });
        return false;
      } else {
        // Other denial cases
        developer.log('Camera permission other denial case: $result',
            name: 'permissions');
        setState(() {
          _hasPermissionError = true;
          _deniedPermission = Permission.camera;
          _errorMessage = _getPermissionErrorMessage('Camera', false);
        });
        return false;
      }
    }
  }

  // Helper method to check photos permission
  Future<bool> _checkPhotosPermission() async {
    // Log for debugging
    developer.log('Checking photos permission on ${Platform.operatingSystem}',
        name: 'permissions');

    if (Platform.isIOS) {
      // On iOS, we need to handle permissions differently
      try {
        // Try to access the photo library directly, which will trigger the permission dialog
        developer.log('iOS: Attempting to access photo library directly',
            name: 'permissions');

        final XFile? testImage = await _picker
            .pickImage(
          source: ImageSource.gallery,
        )
            .catchError((error) {
          // Handle any errors during permission check
          developer.log('Error during photos permission check: $error',
              name: 'permissions');

          // Check if the error is permission-related
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('permission') ||
              errorStr.contains('denied') ||
              errorStr.contains('access')) {
            setState(() {
              _hasPermissionError = true;
              _deniedPermission = Permission.photos;
              _errorMessage =
                  'Photo library access was denied. ${_getPlatformSpecificInstructions()}';
            });
          } else {
            setState(() {
              _errorMessage = 'Error accessing photo library: $error';
            });
          }
          return null; // Return null to indicate error
        });

        // If we got an image, permission was granted
        if (testImage != null) {
          developer.log('iOS: Photos permission granted (got test image)',
              name: 'permissions');
          return true;
        }

        // If we reach here, user likely canceled the picker but permission is granted
        developer.log(
            'iOS: User canceled photo picker but permission might be granted',
            name: 'permissions');
        return true;
      } catch (e) {
        // Check if the error is permission-related
        developer.log('iOS: Photo library access error: $e',
            name: 'permissions');
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains('permission') ||
            errorStr.contains('denied') ||
            errorStr.contains('access')) {
          setState(() {
            _hasPermissionError = true;
            _deniedPermission = Permission.photos;
            _errorMessage =
                'Photo library access was denied. ${_getPlatformSpecificInstructions()}';
          });
          return false;
        }

        // For other errors, just return false
        setState(() {
          _errorMessage = 'Error accessing photo library: $e';
        });
        return false;
      }
    } else {
      // For Android and other platforms, use the permission_handler approach
      // First check the current status
      final status = await Permission.photos.status;

      // Log the initial status for debugging
      developer.log('Photos permission initial status: $status',
          name: 'permissions');

      // If permission is already granted, return true
      if (status.isGranted) {
        developer.log('Photos permission already granted', name: 'permissions');
        return true;
      }

      // For fresh installs or when permission hasn't been requested yet,
      // status.isDenied will be true, but we should still show the system dialog
      // Request the permission - this will show the system dialog
      developer.log('Requesting photos permission...', name: 'permissions');
      final result = await Permission.photos.request();
      developer.log('Photos permission request result: $result',
          name: 'permissions');

      // After request, check the new status
      if (result.isGranted) {
        developer.log('Photos permission granted after request',
            name: 'permissions');
        return true;
      } else if (result.isPermanentlyDenied) {
        // User permanently denied (clicked "Don't ask again" or similar)
        developer.log('Photos permission permanently denied',
            name: 'permissions');
        setState(() {
          _hasPermissionError = true;
          _deniedPermission = Permission.photos;
          _errorMessage = _getPermissionErrorMessage('Photos', true);
        });
        return false;
      } else if (result.isDenied) {
        // User denied but not permanently (clicked "Deny")
        developer.log('Photos permission denied (not permanently)',
            name: 'permissions');
        setState(() {
          _hasPermissionError = true;
          _deniedPermission = Permission.photos;
          _errorMessage =
              'Photos permission was denied. You can try again or enable it in settings.';
        });
        return false;
      } else {
        // Other denial cases
        developer.log('Photos permission other denial case: $result',
            name: 'permissions');
        setState(() {
          _hasPermissionError = true;
          _deniedPermission = Permission.photos;
          _errorMessage = _getPermissionErrorMessage('Photos', false);
        });
        return false;
      }
    }
  }

  // Helper method to get permission error message
  String _getPermissionErrorMessage(
      String permissionName, bool isPermanentlyDenied) {
    if (isPermanentlyDenied) {
      return '$permissionName permission was permanently denied. To use this feature, please enable it in your device settings.\n\n${_getPlatformSpecificInstructions()}';
    } else {
      return '$permissionName permission is needed to continue. Please grant permission when prompted.';
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasPermissionError = false;
      _deniedPermission = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path;
          _imageFile = null;
          _imageSource = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
        _checkIfPermissionError(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // Save the last image source for retry after settings
    _lastImageSource = source;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasPermissionError = false;
      _deniedPermission = null;
    });

    // Set a timeout to ensure loading state is reset even if cancellation isn't detected
    Timer timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _isLoading) {
        developer.log('Timeout occurred, resetting loading state',
            name: 'permissions');
        setState(() {
          _isLoading = false;
        });
      }
    });

    try {
      // Check for camera permission if using camera
      bool hasPermission = source == ImageSource.camera
          ? await _checkCameraPermission()
          : await _checkPhotosPermission();

      if (!hasPermission) {
        setState(() {
          _isLoading = false;
        });
        timeoutTimer.cancel();
        return;
      }

      // On iOS, the permission check already tried to pick an image
      // so we might already have an image or the user might have canceled
      if (Platform.isIOS && _imageFile != null) {
        developer.log('iOS: Image already picked during permission check',
            name: 'permissions');
        timeoutTimer.cancel();
        return;
      }

      // Try to pick the image
      developer.log(
          'Picking image from ${source == ImageSource.camera ? "camera" : "gallery"}',
          name: 'permissions');

      // Use a completer to handle both the result and timeout
      Completer<XFile?> completer = Completer<XFile?>();

      // Start the image picker
      _picker.pickImage(source: source).then((XFile? file) {
        if (!completer.isCompleted) {
          completer.complete(file);
        }
      }).catchError((error) {
        if (!completer.isCompleted) {
          developer.log('Error during image picking: $error',
              name: 'permissions');
          setState(() {
            _errorMessage = 'Error picking image: $error';
            _checkIfPermissionError(error.toString());
          });
          completer.complete(null);
        }
      });

      // Wait for the result or timeout
      final XFile? pickedImage = await completer.future;

      // User might have canceled the picker
      if (pickedImage == null) {
        developer.log('User canceled image picker or error occurred',
            name: 'permissions');
        setState(() {
          _isLoading = false;
        });
        timeoutTimer.cancel();
        return;
      }

      setState(() {
        _imageFile = File(pickedImage.path);
        _filePath = pickedImage.path;
        _fileName = pickedImage.name;
        _imageSource = source == ImageSource.camera ? 'Camera' : 'Gallery';
      });

      timeoutTimer.cancel();
    } catch (e) {
      developer.log('Error picking image: $e', name: 'permissions');
      setState(() {
        _errorMessage = 'Error picking image: $e';
        _checkIfPermissionError(e.toString());
      });
      timeoutTimer.cancel();
    } finally {
      setState(() {
        _isLoading = false;
      });
      timeoutTimer.cancel();
    }
  }

  // Helper method to check if error is permission related
  void _checkIfPermissionError(String errorMessage) {
    final lowerCaseError = errorMessage.toLowerCase();
    if (lowerCaseError.contains('permission') ||
        lowerCaseError.contains('denied') ||
        lowerCaseError.contains('access')) {
      _hasPermissionError = true;

      // Try to determine which permission was denied
      if (lowerCaseError.contains('camera')) {
        _deniedPermission = Permission.camera;
      } else if (lowerCaseError.contains('photo') ||
          lowerCaseError.contains('gallery')) {
        _deniedPermission = Permission.photos;
      }
    }
  }

  // A simpler direct method to handle camera/gallery picking
  Future<void> _directPickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      developer.log(
          'Direct picking image from ${source == ImageSource.camera ? "camera" : "gallery"}',
          name: 'permissions');

      final XFile? pickedImage = await _picker.pickImage(source: source);

      // Always reset loading state immediately
      setState(() {
        _isLoading = false;
      });

      // If user canceled, just return
      if (pickedImage == null) {
        developer.log('User canceled direct image picker', name: 'permissions');
        return;
      }

      // Process the picked image
      setState(() {
        _imageFile = File(pickedImage.path);
        _filePath = pickedImage.path;
        _fileName = pickedImage.name;
        _imageSource = source == ImageSource.camera ? 'Camera' : 'Gallery';
      });
    } catch (e) {
      developer.log('Error in direct image picking: $e', name: 'permissions');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error picking image: $e';
        _checkIfPermissionError(e.toString());
      });
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _hasPermissionError ? 'Permission Required' : 'Error',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            _errorMessage ?? 'An unknown error occurred',
            key: const Key('errorMessage'),
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          if (_hasPermissionError) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Try Again button
                ElevatedButton.icon(
                  onPressed: () {
                    // Clear error state
                    setState(() {
                      _errorMessage = null;
                      _hasPermissionError = false;
                      _deniedPermission = null;
                    });

                    // Try again with the same source
                    if (_deniedPermission == Permission.camera) {
                      _pickImage(ImageSource.camera);
                    } else if (_deniedPermission == Permission.photos) {
                      _pickImage(ImageSource.gallery);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  key: const Key('tryAgainButton'),
                ),
                const SizedBox(width: 16),
                // Open Settings button
                ElevatedButton.icon(
                  onPressed: () async {
                    await _openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                  key: const Key('openSettingsButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const Key('cameraButton'),
                      onPressed: _isLoading
                          ? null
                          : () => _directPickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const Key('galleryButton'),
                      onPressed: _isLoading
                          ? null
                          : () => _directPickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: const Key('pickFileButton'),
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Pick File'),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                _buildErrorWidget()
              else if (_isLoading)
                const CircularProgressIndicator()
              else if (_imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Image from: $_imageSource',
                  key: const Key('imageSource'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('File name: $_fileName'),
                const SizedBox(height: 4),
                Text('File path: $_filePath',
                    style: Theme.of(context).textTheme.bodySmall),
              ] else if (_fileName != null) ...[
                Text(
                  'Selected file: $_fileName',
                  key: const Key('selectedFileName'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('File path: $_filePath',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
