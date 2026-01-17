abstract class PdfRepository {
  /// Converts a list of image paths to a single PDF file.
  /// Returns the path of the generated PDF.
  Future<String> imagesToPdf(List<String> imagePaths);

  /// Merges multiple PDFs into one.
  Future<String> mergePdfs(List<String> pdfPaths);
}
