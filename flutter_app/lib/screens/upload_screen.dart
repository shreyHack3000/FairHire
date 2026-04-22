import 'package:flutter/material.dart';
import 'report_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isUploading = false;
  String? _selectedFileName;
  String? _errorMessage;

  void _pickAndUploadFile() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _selectedFileName = 'sample_hiring_data.csv';
    });

    await Future.delayed(const Duration(seconds: 2));

    final Map<String, dynamic> mockReportData = {
      'date': '2024-01-15',
      'overall_score': 7.8,
      'severity_label': 'High Bias Detected',
      'findings': [
        {
          'cve_id': 'BIAS-001',
          'severity_score': 8.5,
          'evidence': 'Gender bias found in job descriptions',
          'fix': 'Use gender-neutral language in all postings',
          'explanation': 'Male-coded words detected in 67% of listings',
        },
        {
          'cve_id': 'BIAS-002',
          'severity_score': 6.2,
          'evidence': 'Age bias in candidate filtering',
          'fix': 'Remove graduation year filters',
          'explanation': 'Candidates over 45 filtered out disproportionately',
        },
        {
          'cve_id': 'BIAS-003',
          'severity_score': 3.1,
          'evidence': 'Minor location preference detected',
          'fix': 'Consider remote candidates equally',
          'explanation': 'Local candidates preferred by small margin',
        },
      ],
    };

    setState(() {
      _isUploading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(reportData: mockReportData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('FairHire — Upload Data'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: 520,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.upload_file,
                  size: 56,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Upload Hiring Data',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your CSV file to detect bias in hiring process',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF1A73E8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1A73E8).withOpacity(0.04),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFileName != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        size: 40,
                        color: _selectedFileName != null
                            ? Colors.green
                            : const Color(0xFF1A73E8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFileName ?? 'Click to select CSV file',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _selectedFileName != null
                              ? Colors.green
                              : const Color(0xFF1A73E8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supported format: .csv',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              _isUploading
                  ? Column(
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF1A73E8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Analyzing hiring data for bias...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _pickAndUploadFile,
                        icon: const Icon(Icons.analytics, color: Colors.white),
                        label: const Text(
                          'Upload & Analyse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}