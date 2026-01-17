import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../domain/repositories/pdf_repository.dart';

final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  return PdfRepositoryImpl();
});
