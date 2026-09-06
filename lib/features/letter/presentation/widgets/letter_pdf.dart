 

import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class LetterPdf extends StatefulWidget {
  final String url;

  const LetterPdf({
    super.key,
    required this.url,
  });

  @override
  State<LetterPdf> createState() => _LetterPdfState();
}

class _LetterPdfState extends State<LetterPdf> {
  late final String viewType;

  @override
  void initState() {
    super.initState();

    viewType = 'pdf-viewer-${widget.url.hashCode}-${UniqueKey()}';

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: viewType,
    );
  }
}