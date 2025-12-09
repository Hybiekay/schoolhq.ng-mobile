import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

// Only import mobile QR scanner if on Android/iOS
// ignore: uri_does_not_exist
// import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    if (!_isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text("QR Scanner")),
        body: const Center(
          child: Text(
            "QR scanning is only available on Android/iOS.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // QRView(
          //   key: qrKey,
          //   onQRViewCreated: _onQRViewCreated,
          //   overlay: QrScannerOverlayShape(
          //     borderRadius: 16,
          //     borderColor: Colors.blue,
          //     borderLength: 30,
          //     borderWidth: 8,
          //     cutOutSize: 250,
          //   ),
          // ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     controller.pauseCamera();
  //     final scannedSchoolId = scanData.code;
  //     Navigator.pop(context, scannedSchoolId);
  //   });
  // }

  @override
  void dispose() {
    //controller?.dispose();
    super.dispose();
  }
}
