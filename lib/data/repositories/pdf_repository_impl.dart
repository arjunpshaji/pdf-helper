import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';
import '../../domain/repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  @override
  Future<String> imagesToPdf(List<String> imagePaths) async {
    final pdf = pw.Document();

    for (var path in imagePaths) {
      final image = pw.MemoryImage(File(path).readAsBytesSync());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/${const Uuid().v4()}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  @override
  Future<String> mergePdfs(List<String> pdfPaths) async {
    // FOSS Limitation: Cannot easily merge existing PDFs without rasterizing.
    // Placeholder for now.
    throw UnimplementedError("Merge not fully implemented yet");
  }
}
