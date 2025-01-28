import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:gachi_janchi/screens/login_screen.dart';
import 'package:http/http.dart' as http;

import '../utils/secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // String accessToken = SecureStorage.getAccessToken();

  // 토큰 확인 - 테스트용
  void clickBtn() async {
    String? accessToken = await SecureStorage.getAccessToken();
    String? refreshToken = await SecureStorage.getRefreshToken();
    print("accessToken: ${accessToken}");
    print("refreshToken: ${refreshToken}");
  }

  // 자동로그인 확인 - 테스트용
  void checkAutoLogin() async {
    bool? isAutoLogin = await SecureStorage.getIsAutoLogin();
    print("isAutoLogin: ${isAutoLogin}");
  }

  // 로그아웃 처리
  Future<void> logout() async {

    // SecureStorage에서 토큰 삭제
    await SecureStorage.deleteTokens();

    await SecureStorage.saveIsAutoLogin(false);

    await SecureStorage.saveLoginType("");

    // 로그아웃 후 로그인 화면으로 이동
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const LoginScreen())
    );

    // String? refreshToken = await SecureStorage.getRefreshToken();

    // .env에서 서버 URL 가져오기
    // final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/logout");
    // final headers = {'Authorization': 'Bearer $refreshToken'};

    // try {
    //   final response = await http.delete(
    //     apiAddress,
    //     headers: headers
    //   );

    //   if (response.statusCode == 200) {
    //     // 서버에서 refreshToken 삭제 성공
    //     // SecureStorage에서 토큰 삭제
    //     await SecureStorage.deleteTokens();

    //     await SecureStorage.saveIsAutoLogin(false);

    //     await SecureStorage.saveLoginType("");

    //     // 로그아웃 후 로그인 화면으로 이동
    //     Navigator.pushReplacement(
    //       context, 
    //       MaterialPageRoute(builder: (context) => const LoginScreen())
    //     );
    //   } else {
    //     // 서버에서 refreshToken 삭제 실패
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("로그아웃 실패: ${response.body}"))
    //     );
    //   }
    // } catch (e) {
    //   // 예외 처리
    //   showDialog(
    //     context: context,
    //     builder: (_) => const AlertDialog(
    //       title: Text("로그아웃 오류"),
    //       content: Text("서버에 문제가 발생했습니다."),
    //     )
    //   );
    // }
  }

  // 네이버 로그아웃
  Future<void> handleNaverLogout() async {
    try {
      // 1. 로그아웃 요청
      await FlutterNaverLogin.logOut();

      // 2. 네이버 서버의 인증 토큰 삭제
      await FlutterNaverLogin.logOutAndDeleteToken();

      await SecureStorage.saveIsAutoLogin(false);

      await SecureStorage.saveLoginType("");
    } catch (e) {
      print("네이버 로그아웃 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Center(
            child: Column(
              children: [
                const Text("홈 화면"),
                ElevatedButton(
                  onPressed: () {
                    clickBtn();
                  },
                  child: Text("토큰 확인")
                ),
                ElevatedButton(
                  onPressed: () {
                    checkAutoLogin();
                  },
                  child: Text("자동로그인 확인")
                ),
                ElevatedButton(
                  onPressed: () {
                    logout();
                  },
                  child: Text("로그아웃")
                ),
                ElevatedButton(
                  onPressed: () {
                    handleNaverLogout();
                    logout();
                  },
                  child: Text("네이버 로그아웃")
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}