import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadCard extends StatefulWidget {
  final Function(Uint8List bytes, String filename) onFileSelected;
  final VoidCallback onLoadSample;
  final bool isAuditing;

  const FileUploadCard({
    Key? key,
    required this.onFileSelected,
    required this.onLoadSample,
    required this.isAuditing,
  }) : super(key: key);

  @override
  State<FileUploadCard> createState() => _FileUploadCardState();
}

class _FileUploadCardState extends State<FileUploadCard> {
  bool _isHovering = false;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _selectedFileName = file.name;
            _selectedFileBytes = file.bytes;
          });
          widget.onFileSelected(file.bytes!, file.name);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selection error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHovering
              ? const Color(0xFF6366F1)
              : Colors.white.withOpacity(0.12),
          width: _isHovering ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag and drop dropzone UI
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: GestureDetector(
              onTap: widget.isAuditing ? null : _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: _isHovering
                      ? const Color(0xFF6366F1).withOpacity(0.08)
                      : Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovering
                        ? const Color(0xFF6366F1)
                        : Colors.white.withOpacity(0.15),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isAuditing
                            ? Icons.radar_outlined
                            : Icons.cloud_upload_outlined,
                        color: const Color(0xFF818CF8),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isAuditing
                          ? 'Auditing Dataset for Bias Vulnerabilities...'
                          : (_selectedFileName != null
                              ? 'Selected: $_selectedFileName'
                              : 'Click or Drag & Drop Hiring CSV Dataset'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Supports candidate CSVs containing Name, College, Tier, City, Skills, Experience & Status',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.isAuditing) ...[
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 240,
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFF334155),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Executing bias detection engines & Gemini AI recommendations...',
                        style: TextStyle(
                          color: Color(0xFFA5B4FC),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons row: Pick CSV file vs Load Sample Dataset
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: widget.isAuditing ? null : _pickFile,
                icon: const Icon(Icons.folder_open_outlined, size: 18),
                label: const Text('Browse Local CSV File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton.icon(
                onPressed: widget.isAuditing ? null : widget.onLoadSample,
                icon: const Icon(Icons.auto_awesome,
                    size: 18, color: Color(0xFF38BDF8)),
                label: const Text(
                  'Load Sample Hiring Dataset',
                  style: TextStyle(color: Color(0xFF38BDF8)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
