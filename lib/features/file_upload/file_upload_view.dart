import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _fileName;
  String? _filePath;
  bool _isLoading = false;
  File? _imageFile;
  String? _imageSource;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);

      if (pickedImage != null) {
        setState(() {
          _imageFile = File(pickedImage.path);
          _filePath = pickedImage.path;
          _fileName = pickedImage.name;
          _imageSource = source == ImageSource.camera ? 'Camera' : 'Gallery';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                          : () => _pickImage(ImageSource.camera),
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
                          : () => _pickImage(ImageSource.gallery),
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
              if (_isLoading)
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
