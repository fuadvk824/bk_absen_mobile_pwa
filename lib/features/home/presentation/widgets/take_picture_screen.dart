import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TakePictureScreen({super.key, required this.cameras});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  int _cameraIndex = 0;

  Timer? _timer;
  String _timeText = "";

  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startClock();
  }

  void _startClock() {
    _updateTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();

    setState(() {
      _timeText = DateFormat('dd MMM yyyy • HH:mm:ss').format(now);
    });
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      widget.cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;

    _cameraIndex = (_cameraIndex + 1) % widget.cameras.length;

    await _controller?.dispose();
    await _initCamera();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();

    if (!mounted) return;

    Navigator.pop(context, File(image.path));
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    _isFlashOn = !_isFlashOn;

    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ===== CAMERA PREVIEW =====
          SizedBox.expand(child: CameraPreview(_controller!)),

          /// ===== OVERLAY GELAP ATAS =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          /// ===== MARKER TIME STYLE =====
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.22,
            left: MediaQuery.of(context).size.width * 0.05,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ===== JAM BESAR =====
                      Text(
                        DateFormat('HH:mm').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.19,
                          height: 0.95,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,

                          /// FONT LONJONG
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.025,
                      ),

                      /// ===== GARIS KUNING =====
                      Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.008,
                        ),
                        width: 3,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.025,
                      ),

                      /// ===== TANGGAL + HARI =====
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.008,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.045,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),

                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.003,
                              ),

                              Text(
                                DateFormat('EEEE').format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'RobotoCondensed',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.012),

                  /// ===== LOKASI =====
                  Text(
                    "Jl Raya Kepatihan, Hendosari, Kepatihan\nGresik, Jawa Timur",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ===== SHUTTER AREA =====
          /// ===== BOTTOM ACTION =====
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.07,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.15,
                    child: GestureDetector(
                      onTap: _toggleFlash,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Icon(
                          _isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  /// ===== SHUTTER BUTTON (BENAR-BENAR TENGAH) =====
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.22,
                      height: MediaQuery.of(context).size.width * 0.22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.17,
                          height: MediaQuery.of(context).size.width * 0.17,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// ===== SWITCH CAMERA =====
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.15,
                    child: GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.cameraswitch_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
