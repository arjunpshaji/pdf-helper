import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

class PdfToImageScreen extends StatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  State<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends State<PdfToImageScreen> {
  bool _isLoading = false;
  String _status = '';

  Future<void> _pickAndConvert() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _isLoading = true;
      _status = 'Opening PDF...';
    });

    try {
      final doc = await PdfDocument.openFile(result.files.single.path!);
      final pages = doc.pagesCount;
      final outputDir = await getApplicationDocumentsDirectory();
      final List<XFile> outputFiles = [];

      for (int i = 1; i <= pages; i++) {
        setState(() => _status = 'Converting Page $i of $pages...');
        final page = await doc.getPage(i);
        final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );

        if (pageImage != null) {
          final path = '${outputDir.path}/page_$i.png';
          final file = File(path);
          await file.writeAsBytes(pageImage.bytes);
          outputFiles.add(XFile(path));
        }
        await page.close();
      }
      await doc.close();

      setState(() {
        _isLoading = false;
        _status = 'Conversion Complete!';
      });

      if (mounted) {
        Share.shareXFiles(outputFiles, text: 'Converted Images');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF to Image')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_aspect_ratio,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Convert PDF Pages to Images',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_status),
              ] else
                FilledButton.icon(
                  onPressed: _pickAndConvert,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select PDF'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
