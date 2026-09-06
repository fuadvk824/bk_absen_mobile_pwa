import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:web/web.dart' as web;

import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/toast_helper.dart';

class LeavePdf extends StatefulWidget {
  final String fileUrl;
  final String title;

  const LeavePdf({super.key, required this.fileUrl, required this.title});

  @override
  State<LeavePdf> createState() => _LeavePdfState();
}

class _LeavePdfState extends State<LeavePdf> {
  bool _isDownloading = false;
  bool _hasError = false;

  bool get _isPdf {
    return _getExtension(widget.fileUrl) == 'pdf';
  }

  bool get _isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

    return imageExtensions.contains(_getExtension(widget.fileUrl));
  }

  String _getExtension(String url) {
    try {
      final uri = Uri.parse(url);

      // Ambil extension dari path.
      // Query seperti ?token=xxx tidak ikut.
      final path = uri.path.toLowerCase();

      if (!path.contains('.')) {
        return '';
      }

      return path.split('.').last;
    } catch (_) {
      return '';
    }
  }

  String _getFileExtension() {
    final extension = _getExtension(widget.fileUrl);

    if (extension.isNotEmpty) {
      return extension;
    }

    if (_isPdf) {
      return 'pdf';
    }

    if (_isImage) {
      return 'jpg';
    }

    return 'file';
  }

  String _generateFileName() {
    final title = widget.title
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(' ', '_');

    final extension = _getFileExtension();

    return 'cuti_$title.$extension';
  }

  Future<void> _downloadFile() async {
    if (_isDownloading) {
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final anchor = web.HTMLAnchorElement()
        ..href = widget.fileUrl
        ..download = _generateFileName()
        ..target = '_blank';

      anchor.click();

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      ToastHelper.success(context, message: 'Download file dimulai');
    } catch (e) {
      debugPrint('DOWNLOAD LEAVE FILE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      ToastHelper.error(context, message: 'Gagal download file');
    }
  }

  void _showError() {
    if (!mounted) return;

    if (_hasError) {
      return;
    }

    setState(() {
      _hasError = true;
    });
  }

  Widget _buildImage() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5,
      child: Center(
        child: Image.network(
          widget.fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('LEAVE IMAGE ERROR: $error');

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showError();
            });

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildPdf() {
    return SfPdfViewer.network(
      widget.fileUrl,
      onDocumentLoadFailed: (details) {
        debugPrint('LEAVE PDF ERROR: ${details.error}');

        debugPrint('LEAVE PDF DESCRIPTION: ${details.description}');

        _showError();

        if (mounted) {
          ToastHelper.error(context, message: 'Gagal membuka file PDF');
        }
      },
    );
  }

  Widget _buildUnknownFile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'File tidak dapat ditampilkan langsung',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Silakan download file untuk membukanya.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadFile,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Download File'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isImage
                  ? Icons.image_not_supported_outlined
                  : Icons.picture_as_pdf_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'File tidak dapat dibuka',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'File tidak tersedia atau gagal dimuat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return _buildError();
    }

    // =========================
    // PDF
    // =========================
    if (_isPdf) {
      return _buildPdf();
    }

    // =========================
    // IMAGE
    // =========================
    if (_isImage) {
      return _buildImage();
    }

    // =========================
    // FILE LAIN
    // =========================
    return _buildUnknownFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,

        iconTheme: const IconThemeData(color: Colors.white),

        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Download File',
            onPressed: _isDownloading ? null : _downloadFile,
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_outlined, color: Colors.white),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: _buildContent(),
    );
  }
}
