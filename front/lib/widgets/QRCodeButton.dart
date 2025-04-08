import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/qr_code_scanner.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRCodeButton extends StatefulWidget {
  final void Function(int)? changeTap;

  const QRCodeButton({
    super.key,
    required this.changeTap
  });

  @override
  State<QRCodeButton> createState() => _QRCodeButtonState();
}

class _QRCodeButtonState extends State<QRCodeButton> {

  void qrScanData() async {
    // QrCodeScanner 화면으로 이동
    // QR코드 스캔한 결과를 value로 받아서 사용

    // 실제 핸드폰으로 qr코드를 찍을 수 있을 때 사용
    Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => const QrCodeScanner(),
        settings: RouteSettings(name: 'qr_scan')))
      .then((value) async{
        print('QR value: ${value}');
        if (value != null && value.toString().isNotEmpty) {
          await getRestaurant(value);
          
          widget.changeTap?.call(3);
        }
      }
    );

    // 임시로 음식점 아이디를 통해 정보를 가져오는 것
    // getRestaurant("67c9e0bb79b5e9cfd182e151");
  }

  // 음식점 아이디로 재료 요청하는 함수
  Future<void> getRestaurant(String restaurantId) async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/ingredientId?restaurantId=$restaurantId");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        print("방문 음식점에 대한 재료 아이디 요청 완료");
        
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);
        final ingredientId = data["ingredientId"];
        print("ingredientId: $ingredientId");

        await addVisitedRestaurant(restaurantId, ingredientId);

      } else {
        print("방문 음식점에 대한 재료 아이디를 불러올 수 없습니다.");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  // 방문한 음식점 저장하는 함수
  Future<void> addVisitedRestaurant(String restaurantId, int ingredientId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/visited-restaurant");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };

    try {
      print("방문한 음식점 저장 요청 보내기 시작");
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          "restaurantId": restaurantId,
          "ingredientId": ingredientId
        })
      );

      if (response.statusCode == 200) {
        print("방문 음식점 저장 요청 완료");
        
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("result: $data");


      } else {
        print("방문 음식점 저장 요청 실패");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.qr_code_scanner,
        size: 30,
      ),
      onPressed: () {
        print("QR코드 스캐너 버튼 클릭!!!!!!");
        qrScanData();
      }
    );
  }
}