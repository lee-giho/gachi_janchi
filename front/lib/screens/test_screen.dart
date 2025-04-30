import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/screens/login_screen.dart';
import 'package:gachi_janchi/screens/main_screen.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';

import '../utils/secure_storage.dart';

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});

  @override
  ConsumerState<TestScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<TestScreen> {

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

    // 즐겨찾기 목록 초기화
    ref.read(favoriteProvider.notifier).resetFavoriteRestaurants();

    // SecureStorage에서 토큰 삭제
    await SecureStorage.deleteTokens();

    // 자동 로그인 상태 해제
    await SecureStorage.saveIsAutoLogin(false);

    // 로그인 타입 초기화
    await SecureStorage.saveLoginType("");

    // 로그아웃 후 로그인 화면으로 이동
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false // false를 반환하여 모든 기존 화면 제거
    );
  }

  // 네이버 로그아웃
  Future<void> handleNaverLogout() async {
    try {
      // 로그아웃 요청
      await FlutterNaverLogin.logOut();

      // 네이버 서버의 인증 토큰 삭제
      await FlutterNaverLogin.logOutAndDeleteToken();

      // 즐겨찾기 목록 초기화
      ref.read(favoriteProvider.notifier).resetFavoriteRestaurants();

      // SecureStorage에서 토큰 삭제
      await SecureStorage.deleteTokens();

      // 자동 로그인 상태 해제
      await SecureStorage.saveIsAutoLogin(false);

      // 로그인 타입 초기화
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen())
                    );
                  },
                  child: Text("메인 화면으로 이동")
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen())
                    );
                  },
                  child: Text("메인 화면으로 이동")
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}