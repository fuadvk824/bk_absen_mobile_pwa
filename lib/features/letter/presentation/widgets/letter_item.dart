
import 'package:flutter/material.dart';
import 'package:bk_absen/model/letter_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LetterItem extends StatefulWidget {
  final LetterModel letter;
  final Future<String?> Function()? onRead;

  const LetterItem({
    super.key,
    required this.letter,
    this.onRead,
  });

  @override
  State<LetterItem> createState() => _LetterItemState();
}

class _LetterItemState extends State<LetterItem> {
  bool _isDownloading = false;
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    _isRead = widget.letter.isRead;
  }

  @override
  void didUpdateWidget(covariant LetterItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.letter.isRead != widget.letter.isRead) {
      _isRead = widget.letter.isRead;
    }
  }

  String _getDayShort(int weekday) {
    const days = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];

    return days[weekday - 1];
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month - 1];
  }

  Color _getLetterColor(String jenisSurat) {
    switch (jenisSurat.toLowerCase()) {
      case 'sp1':
        return Colors.orange;

      case 'sp2':
        return Colors.deepOrange;

      case 'sp3':
        return Colors.red;

      case 'probation':
        return Colors.blue;

      case 'paklaring':
        return Colors.green;

      default:
        return AppColors.primary;
    }
  }

  String _getLetterTitle(String jenisSurat) {
    switch (jenisSurat.toLowerCase()) {
      case 'sp1':
        return 'Surat Peringatan 1';

      case 'sp2':
        return 'Surat Peringatan 2';

      case 'sp3':
        return 'Surat Peringatan 3';

      case 'probation':
        return 'Surat Probation';

      case 'paklaring':
        return 'Surat Paklaring';

      default:
        return jenisSurat;
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) return;

    final oldPdfUrl = widget.letter.pdfUrl;

    if (oldPdfUrl == null || oldPdfUrl.trim().isEmpty) {
      ToastHelper.warning(
        context,
        message: 'PDF tidak tersedia',
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      String downloadUrl = oldPdfUrl.trim();

      // Jika surat belum dibaca, panggil API untuk
      // menandai surat dibaca dan mendapatkan URL PDF terbaru.
      if (!_isRead) {
        final newPdfUrl = await widget.onRead?.call();

        if (newPdfUrl == null || newPdfUrl.trim().isEmpty) {
          throw Exception(
            'Gagal mendapatkan PDF surat yang sudah dibaca',
          );
        }

        downloadUrl = newPdfUrl.trim();
      }

      // Validasi URL PDF.
      final uri = Uri.tryParse(downloadUrl);

      if (uri == null ||
          !uri.hasAuthority ||
          (uri.scheme != 'https' && uri.scheme != 'http')) {
        throw Exception('URL PDF tidak valid');
      }

      // Buka PDF di tab browser baru.
      final launched = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );

      if (!launched) {
        throw Exception('Gagal membuka PDF');
      }

      if (!mounted) return;

      // Perbarui status lokal setelah API berhasil
      // dan browser menerima permintaan membuka PDF.
      if (!_isRead) {
        setState(() {
          _isRead = true;
        });
      }

      ToastHelper.success(
        context,
        message: 'PDF berhasil dibuka',
      );
    } catch (e) {
      if (!mounted) return;

      ToastHelper.error(
        context,
        message: 'Gagal membuka PDF. Silakan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? date;

    try {
      date = DateTime.parse(widget.letter.tanggalSurat);
    } catch (_) {
      date = null;
    }

    final letterColor = _getLetterColor(
      widget.letter.jenisSurat,
    );

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Tanggal surat.
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (date != null) ...[
                      Text(
                        _getDayShort(date.weekday),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date.day.toString(),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getMonthShort(date.month),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ] else
                      const Icon(
                        Icons.description,
                        color: Colors.white,
                        size: 30,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              // Informasi surat.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLetterTitle(
                                  widget.letter.jenisSurat,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: letterColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.letter.nomorSurat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isRead
                                        ? Icons.mark_email_read
                                        : Icons.mark_email_unread,
                                    size: 16,
                                    color: _isRead
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isRead ? 'Dibaca' : 'Baru',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _isRead
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    const Divider(),

                    const SizedBox(height: 2),

                    // Tombol buka PDF.
                    if (widget.letter.pdfUrl != null &&
                        widget.letter.pdfUrl!.isNotEmpty)
                      SizedBox(
                        height: 35,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _isDownloading
                              ? null
                              : _downloadPdf,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              if (_isDownloading)
                                const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.download_outlined,
                                  size: 17,
                                  color: AppColors.primary,
                                ),

                              const SizedBox(width: 6),

                              Text(
                                _isDownloading
                                    ? 'Membuka PDF...'
                                    : 'Lihat & Download',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'PDF tidak tersedia',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
