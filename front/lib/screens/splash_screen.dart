import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gachi_janchi/screens/home_screen.dart';
import 'package:gachi_janchi/screens/login_screen.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // 자동 로그인 체크 및 상태 확인
  Future<void> checkLoginStatus() async {

    String? accessToken = await SecureStorage.getAccessToken();
    String? refreshToken = await SecureStorage.getRefreshToken();

    print("유저 접속");
    print("accessToken: ${accessToken}");
    print("refreshToken: ${refreshToken}");

    if (accessToken != null && refreshToken != null) {
      // 토큰이 있다면 유효성 검사 후 로그인 처리
      bool isValid = await validateAccessToken(accessToken);
      if (isValid) {
        // accessToken이 유효하면 홈 화면으로 이동
        print("accessToken 유효, 홈으로 이동");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      } else {
        // accessToken이 만료되었으면 refreshToken으로 새로운 accessToken을 받아옴
        print("accessToken이 만료, refreshToken으로 새로운 accessToken 요청");
        bool isRefreshed = await refreshAccessToken(refreshToken);
        if (isRefreshed) {
          print("새로운 accessToken 발급 완료, 홈으로 이동");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
          );
        } else {
          print("새로운 accessToken 발급 실패, 로그인화면으로 이동");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen())
          );
        }
      }
    } else {
      print("토큰이 없음, 로그인화면으로 이동");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
    }
  }

  // accessToken 유효성 검사
  Future<bool> validateAccessToken(String accessToken) async {
    
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/token-validation");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        // 유효한 accessToken
        print("유효한 accessToken");
        return true;
      } else {
        // 유효하지 않은 accessToken
        print("유효하지 않은 accessToken");
        return false;
      }
    } catch (e) {
      // 예외처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
      return false;
    }
  }

  // refreshToken으로 새로운 accessToken을 발급
  Future<bool> refreshAccessToken(String refreshAccessToken) async {
    
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/token-refresh");
    final headers = {'Authorization': 'Bearer $refreshAccessToken'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        // 응답 body를 json으로 파싱
        final Map<String, dynamic> responseData = json.decode(response.body);

        // 새로운 accessToken을 받아오고 SecureStorage에 저장
        String newAccessToken = responseData['newAccessToken'];
        await SecureStorage.saveAccessToken(newAccessToken);

        print("refreshToken으로 새로운 accessToken 발급");
        return true;
      } else {
        // refreshToken이 만료되었거나 갱신 실패

        print("refreshToken이 만료되거나 갱신 실패");
        return false;
      }
    } catch (e) {
      // 예외처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 로딩 중 표시
      ),
    );
  }
}