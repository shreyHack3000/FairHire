import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isLoading = false;
  String _loadingText = 'Initializing scan...';
  PlatformFile? _selectedFile;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _runAudit() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _loadingText = 'Scanning for bias patterns...';
    });

    try {
      // Step 1: Visual feedback
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _loadingText = 'Running statistical analysis...');

      // Step 2: Read the CSV file bytes
      String csvContent = "";
      if (_selectedFile!.bytes != null) {
        csvContent = utf8.decode(_selectedFile!.bytes!);
      } else {
        throw Exception("Could not read file. Please try again.");
      }

      // Step 3: Send file to Flask Backend
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://fairhire-backend-6nzl.onrender.com/audit'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ),
      );

      setState(() => _loadingText = 'Generating AI recommendations...');
      
      var response = await request.send().timeout(const Duration(minutes: 2));
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var report = jsonDecode(responseData);
        
        if (report['status'] == 'error') {
          throw Exception(report['message'] ?? 'Unknown error occurred.');
        }

        // Step 4: Navigate to report
        if (mounted) {
          Navigator.pushNamed(context, '/report', arguments: report);
        }
      } else {
        throw Exception('Server returned ${response.statusCode}. Make sure the Flask backend is running.');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bias Audit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Center(
        child: _isLoading 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.staggeredDotsWave(
                  color: const Color(0xFFEF4444),
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(_loadingText, style: Theme.of(context).textTheme.titleLarge),
              ],
            )
          : Container(
              width: 600,
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _selectedFile != null ? const Color(0xFF22C55E) : Colors.white.withOpacity(0.2),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                            size: 80,
                            color: _selectedFile != null ? const Color(0xFF22C55E) : Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _selectedFile != null ? _selectedFile!.name : 'Upload Hiring Dataset',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile != null ? '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB' : 'Supports .CSV files only',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedFile != null ? _runAudit : null,
                      child: const Text('START AUDIT SCAN'),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
