import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/image_to_pdf_screen.dart';
import 'presentation/screens/office_to_pdf_screen.dart';
import 'presentation/screens/pdf_processor_screen.dart';
import 'presentation/screens/pdf_to_image_screen.dart';
import 'presentation/screens/placeholder_screen.dart';
import 'presentation/screens/scan_pdf_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PDF Offline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardScreen(),

      // Page transition animations
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          '/settings': (context) => const SettingsScreen(),
          '/img_to_pdf': (context) => const ImageToPdfScreen(),
          '/doc_to_pdf': (context) => const OfficeToPdfScreen(),
          '/scan_pdf': (context) => const ScanPdfScreen(),
          '/pdf_to_img': (context) => const PdfToImageScreen(),
          '/merge_pdf': (context) =>
              const PdfProcessorScreen(type: PdfConfigType.merge),
          '/split_pdf': (context) =>
              const PdfProcessorScreen(type: PdfConfigType.split),
          '/compress_pdf': (context) =>
              const PdfProcessorScreen(type: PdfConfigType.compress),
          '/rotate_pdf': (context) =>
              const PdfProcessorScreen(type: PdfConfigType.rotate),
          '/lock_pdf': (context) =>
              const PdfProcessorScreen(type: PdfConfigType.protect),
          '/unlock_pdf': (context) => const PlaceholderScreen(
            title: 'Unlock PDF',
            message: 'Coming in v1.1',
          ),
          '/watermark': (context) => const PlaceholderScreen(
            title: 'Watermark',
            message: 'Coming in v1.1',
          ),
        };

        final widgetBuilder = routes[settings.name];
        if (widgetBuilder == null) return null;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              widgetBuilder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.05);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
      },
    );
  }
}
