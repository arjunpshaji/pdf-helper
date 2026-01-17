import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/datasources/apps_script_service.dart';

class OfficeToPdfScreen extends StatefulWidget {
  const OfficeToPdfScreen({super.key});

  @override
  State<OfficeToPdfScreen> createState() => _OfficeToPdfScreenState();
}

class _OfficeToPdfScreenState extends State<OfficeToPdfScreen> {
  final _service = AppsScriptService();
  bool _isConverting = false;
  String? _statusMessage;

  Future<void> _pickAndConvert() async {
    // 1. Check URL first
    final url = await _service.getScriptUrl();
    if (url == null || url.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please configure Server URL in Settings first.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ),
      );
      return;
    }

    // 2. Pick File
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'doc', 'xlsx', 'xls', 'pptx', 'ppt'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;

      setState(() {
        _isConverting = true;
        _statusMessage = "Uploading & Converting...";
      });

      try {
        // 3. Convert via Online Script
        final pdfBytes = await _service.convertOfficeToPdf(filePath);

        // 4. Save Result
        final output = await getApplicationDocumentsDirectory();
        final originalName = result.files.single.name.split('.').first;
        final file = File('${output.path}/$originalName.pdf');
        await file.writeAsBytes(pdfBytes);

        setState(() {
          _statusMessage = "Success!";
          _isConverting = false;
        });

        if (mounted) {
          Share.shareXFiles([XFile(file.path)], text: 'Converted PDF');
        }
      } catch (e) {
        setState(() {
          _statusMessage = "Error: $e";
          _isConverting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Office to PDF (Online)')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Convert Word, Excel, PowerPoint to PDF',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uses your personal Google Apps Script server (Unlimited & Free).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (_isConverting) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_statusMessage ?? 'Processing...'),
                ] else ...[
                  if (_statusMessage != null)
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _statusMessage!.startsWith('Error')
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickAndConvert,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Select File'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
