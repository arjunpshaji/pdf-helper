import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:share_plus/share_plus.dart';

enum PdfConfigType { merge, split, compress, rotate, protect }

class PdfProcessorScreen extends StatefulWidget {
  final PdfConfigType type;
  const PdfProcessorScreen({super.key, required this.type});

  @override
  State<PdfProcessorScreen> createState() => _PdfProcessorScreenState();
}

class _PdfProcessorScreenState extends State<PdfProcessorScreen> {
  bool _isLoading = false;
  String _status = '';
  final List<String> _selectedFiles = [];
  final _passwordController = TextEditingController();

  String get _title {
    switch (widget.type) {
      case PdfConfigType.merge:
        return 'Merge PDFs';
      case PdfConfigType.split:
        return 'Split PDF';
      case PdfConfigType.compress:
        return 'Compress PDF';
      case PdfConfigType.rotate:
        return 'Rotate PDF';
      case PdfConfigType.protect:
        return 'Protect PDF';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case PdfConfigType.merge:
        return Icons.merge;
      case PdfConfigType.split:
        return Icons.call_split;
      case PdfConfigType.compress:
        return Icons.compress;
      case PdfConfigType.rotate:
        return Icons.rotate_right;
      case PdfConfigType.protect:
        return Icons.lock;
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: widget.type == PdfConfigType.merge,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.whereType<String>());
      });
    }
  }

  Future<void> _process() async {
    if (_selectedFiles.isEmpty) return;

    if (widget.type == PdfConfigType.protect &&
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Processing...';
    });

    try {
      final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

      for (var filePath in _selectedFiles) {
        final document = await pdfx.PdfDocument.openFile(filePath);
        final pageCount = document.pagesCount;

        for (int i = 1; i <= pageCount; i++) {
          setState(() => _status = 'Page $i of $pageCount...');

          final page = await document.getPage(i);
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: pdfx.PdfPageImageFormat.jpeg,
            quality: widget.type == PdfConfigType.compress ? 50 : 80,
          );

          if (pageImage != null) {
            final imageProvider = pw.MemoryImage(pageImage.bytes);
            var pageFormat = PdfPageFormat.a4;

            if (widget.type == PdfConfigType.rotate) {
              pageFormat = PdfPageFormat(pageFormat.height, pageFormat.width);
            }

            pdf.addPage(
              pw.Page(
                pageFormat: pageFormat,
                build: (context) => pw.Center(child: pw.Image(imageProvider)),
              ),
            );
          }
          await page.close();
        }
        await document.close();
      }

      final outputDocs = await getApplicationDocumentsDirectory();
      final fileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${outputDocs.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      setState(() {
        _isLoading = false;
        _status = 'Done!';
      });

      if (mounted) {
        Share.shareXFiles([XFile(file.path)], text: 'Processed PDF');
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
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: _selectedFiles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icon,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Files Selected',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select PDF files to $_title',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select PDF Files'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  if (_isLoading)
                    LinearProgressIndicator(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainer,
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.picture_as_pdf),
                            ),
                            title: Text(
                              _selectedFiles[index]
                                  .split(Platform.pathSeparator)
                                  .last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('File ${index + 1}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(
                                () => _selectedFiles.removeAt(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.type == PdfConfigType.protect)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter password for PDF',
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(_status, textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.add),
                              label: const Text('Add More'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _process,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Process'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
