import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // qr_code_scanner의 hot reload를 보장하려면 안드로이드의 경우에는 pauseCamera(), ios의 경우에는 resumeCamera()를 처리해줘야 한다.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // buildQrView를 실행하면서 스캐너를 뷰에 뿌려줌
          Expanded(
            flex: 4,
            child: buildQrView(context)
          )
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) {
    // 디바이스의 크기에 따라 scanArea를 반응형으로 지정
    var scanArea = (
        MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400
      )
      ? 150.0
      : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated, // QRView가 생성되면 onQRViewCreated를 실행

      // QR을 읽힐 네모난 칸의 디자인 설정
      overlay: QrScannerOverlayShape(
        borderColor: const Color.fromRGBO(122, 11, 11, 1),
        borderRadius: 15,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
        // 배경 반투명 처리
        overlayColor: Colors.black.withOpacity(0.8)
      ),

      // 카메라 사용 권한 체크
      onPermissionSet: (ctrl, b) => onPermissionSet(context, ctrl, b),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller; // 컨트롤러를 통해 스캐너 제어
    });

    // 스캔된 데이터가 하나만 처리되도록 제어
    bool isScanned = false;

    controller.scannedDataStream.listen((scanData) async{
      if (!isScanned) {
        isScanned = true; // 이미 스캔했으므로 추가로 스캔하지 않음
        await controller.pauseCamera(); // 인식돼서 카메라를 멈춤  

        setState(() {
          result = scanData; // 스캔된 데이터
        });

        print('barcode_result-----------------');
        print(result!.code);

        if (scanData.code!.isNotEmpty) {
          // QR이 인식 되었을 경우 스캐너를 닫으며 결과 리턴
          print('QRScanner 종료');

          // Navigator.pop을 비동기적으로 호출
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context, result!.code); // QR코드가 인식된 후 pop 호출
          });
        }
      }      
    });
  }

  // 권한 체크를 위한 함수
  void onPermissionSet(BuildContext context, QRViewController ctrl, bool b) {
    if (!b) { // 카메라 사용 권한이 없을 경우
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("카메라 권한이 없습니다.")
        )
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}