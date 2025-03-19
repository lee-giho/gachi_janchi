import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/screens/main_screen.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gachi_janchi/screens/test_screen.dart';
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
  // 소셜 로그인일 경우, isAutoLogin 여부 상관 없이 토큰이 있다면 로그인
  // 로컬 로그인일 경우, isAutoLogin 여부에 따라 로그인이 되거나 토큰을 삭제하고 로그인 화면으로 이동
  Future<void> checkLoginStatus() async {

    String? loginType = await SecureStorage.getLoginType();
    bool? isAutoLogin = await SecureStorage.getIsAutoLogin() ?? false;

    String? accessToken = await SecureStorage.getAccessToken();
    String? refreshToken = await SecureStorage.getRefreshToken();

    final container = ProviderContainer();

    print("유저 접속");
    print("loginType: ${loginType}");
    print("isAutoLogin: ${isAutoLogin}");

    print("accessToken: ${accessToken}");
    print("refreshToken: ${refreshToken}");
    
    // 소셜 로그인일 경우
    if (loginType == "google" || loginType == "naver") {
      if (accessToken != null && refreshToken != null) {
        // 토큰이 있다면 유효성 검사 후 로그인 처리
        bool isValid = await validateAccessToken(accessToken);
        if (isValid) {
        
        // 즐겨찾기 목록 불러오기
        await container.read(favoriteProvider.notifier).fetchFavoriteRestaurants();

          // accessToken이 유효하면 홈 화면으로 이동
          print("accessToken 유효, 홈으로 이동");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen())
          );
        } else {
          // accessToken이 만료되었으면 refreshToken으로 새로운 accessToken을 받아옴
          print("accessToken이 만료, refreshToken으로 새로운 accessToken 요청");
          bool isRefreshed = await refreshAccessToken(refreshToken);
          if (isRefreshed) {

            // 즐겨찾기 목록 불러오기
            await container.read(favoriteProvider.notifier).fetchFavoriteRestaurants();

            print("새로운 accessToken 발급 완료, 홈으로 이동");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen())
            );
          } else {
            print("refreshToken이 만료, 새로운 accessToken 발급 실패, 로그인화면으로 이동");
            
            await SecureStorage.deleteTokens();

            await SecureStorage.saveIsAutoLogin(false);

            await SecureStorage.saveLoginType("");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen())
            );
          }
        }
      } else {
        print("토큰이 없음, 로그인화면으로 이동");
        await SecureStorage.saveIsAutoLogin(false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
    } else { // 로컬 로그인일 경우
      // 자동로그인이 true일 경우
      if (isAutoLogin) {

        print("자동로그인 O");

        if (accessToken != null && refreshToken != null) {
          // 토큰이 있다면 유효성 검사 후 로그인 처리
          bool isValid = await validateAccessToken(accessToken);
          if (isValid) {

            // 즐겨찾기 목록 불러오기
            await container.read(favoriteProvider.notifier).fetchFavoriteRestaurants();

            // accessToken이 유효하면 홈 화면으로 이동
            print("accessToken 유효, 홈으로 이동");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen())
            );
          } else {
            // accessToken이 만료되었으면 refreshToken으로 새로운 accessToken을 받아옴
            print("accessToken이 만료, refreshToken으로 새로운 accessToken 요청");
            bool isRefreshed = await refreshAccessToken(refreshToken);
            if (isRefreshed) {

              // 즐겨찾기 목록 불러오기
              await container.read(favoriteProvider.notifier).fetchFavoriteRestaurants();

              print("새로운 accessToken 발급 완료, 홈으로 이동");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen())
              );
            } else {
              print("refreshToken이 만료, 새로운 accessToken 발급 실패, 로그인화면으로 이동");
            
              await SecureStorage.deleteTokens();

              await SecureStorage.saveIsAutoLogin(false);

              await SecureStorage.saveLoginType("");
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen())
              );
            }
          }
        } else {
          print("토큰이 없음, 로그인화면으로 이동");
          await SecureStorage.saveIsAutoLogin(false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen())
          );
        }
      } else {
        print("자동로그인 X");
        await SecureStorage.deleteTokens();
        container.read(favoriteProvider.notifier).resetFavoriteRestaurants();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      }
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