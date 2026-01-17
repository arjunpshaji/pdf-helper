# PDF Offline - Unlimited Free PDF Tools

A modern Flutter application for PDF manipulation with both offline and online capabilities.

## Features

### Offline Features
- **Image to PDF** - Convert multiple images to a single PDF document
- **Scan to PDF** - Use your camera to scan documents and create PDFs
- **PDF to Image** - Extract pages from PDFs as high-quality images

### Online Features (via Google Apps Script)
- **Office to PDF** - Convert Word, Excel, and PowerPoint files to PDF
- **Merge PDFs** - Combine multiple PDF files into one
- **Split PDF** - Extract specific pages from PDFs
- **Compress PDF** - Reduce PDF file size
- **Rotate PDF** - Rotate PDF pages
- **Protect PDF** - Add password protection to PDFs

## Architecture

- **Clean Architecture** - Separation of concerns with Domain, Data, and Presentation layers
- **State Management** - Flutter Riverpod for dependency injection and state management
- **Modern UI** - Glassmorphism effects, smooth animations, and Material Design 3
- **Environment Variables** - Secure configuration management

## Setup

### Prerequisites
- Flutter SDK (latest stable)
- Google Apps Script account (for online features)

### Installation

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd pdf_offline
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up environment variables:
   ```bash
   copy .env.example .env
   ```
   Edit `.env` and add your Google Apps Script URL (see below).

### Google Apps Script Setup

1. Go to [script.google.com](https://script.google.com)
2. Create a new project
3. Copy the code from `server/code.gs`
4. Deploy as Web App (Execute as: Me, Access: Anyone)
5. Copy the Web App URL to your `.env` file

See `.env.README.md` for detailed instructions.

## Running the App

```bash
flutter run
```

## Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

## Project Structure

```
lib/
├── core/                 # Core utilities and themes
├── data/                 # Data layer (repositories, services)
├── domain/               # Domain layer (entities, interfaces)
└── presentation/         # UI layer (screens, widgets, providers)
    ├── providers/        # Riverpod providers
    ├── screens/          # App screens
    └── widgets/          # Reusable widgets
```

## License

This project uses FOSS (Free and Open Source Software) libraries and is suitable for commercial use.

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Google ML Kit** - Document scanning
- **pdf package** - PDF generation
- **pdfx** - PDF rendering
- **dio** - HTTP client
- **Google Apps Script** - Serverless backend for conversions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
