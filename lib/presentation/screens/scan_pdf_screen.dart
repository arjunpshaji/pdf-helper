import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:share_plus/share_plus.dart';

class ScanPdfScreen extends StatefulWidget {
  const ScanPdfScreen({super.key});

  @override
  State<ScanPdfScreen> createState() => _ScanPdfScreenState();
}

class _ScanPdfScreenState extends State<ScanPdfScreen> {
  DocumentScanner? _documentScanner;

  @override
  void initState() {
    super.initState();
    final options = DocumentScannerOptions(
      documentFormat: DocumentFormat.pdf,
      mode: ScannerMode.full,
      pageLimit: 0,
      isGalleryImport: true,
    );
    _documentScanner = DocumentScanner(options: options);
    // Auto-trigger scan on open
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  @override
  void dispose() {
    _documentScanner?.close();
    super.dispose();
  }

  Future<void> _startScan() async {
    try {
      final result = await _documentScanner?.scanDocument();
      if (result != null && result.pdf != null && mounted) {
        final pdfPath = result.pdf!.uri;
        // Show success and option to share
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Scan Saved: $pdfPath')));
          Share.shareXFiles([XFile(pdfPath)], text: 'Scanned Document');
        }
      } else {
        if (mounted) Navigator.pop(context); // User cancelled
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Launching Scanner...'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _startScan,
              child: const Text('Retry Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
