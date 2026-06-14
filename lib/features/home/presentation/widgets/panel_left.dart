import 'dart:typed_data';
import 'package:flutter/material.dart';

class PanelLeft extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onOpenCamera;

  const PanelLeft({
    super.key,
    required this.imageBytes,
    required this.onOpenCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 200,
            color: Colors.grey[200],
            child: imageBytes == null
                ? const Center(child: Text("Belum ada foto"))
                : Image.memory(imageBytes!, fit: BoxFit.cover),
          ),
          ElevatedButton(
            onPressed: onOpenCamera,
            child: const Text("Ambil Foto"),
          )
        ],
      ),
    );
  }
}