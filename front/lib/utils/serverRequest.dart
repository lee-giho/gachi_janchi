import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/screens/login_screen.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServerRequest {

  Future<bool> serverRequest(Future<bool> Function() asyncFuction, BuildContext context) async{
    log("asyncFuction을 서버에 요청 시작 - 첫 번째");
    final asyncFunctionResult = await asyncFuction();
    log("asyncFunctionResult: $asyncFunctionResult");
    if (!asyncFunctionResult) {
      log("서버에 요청 실패 - accessToken 재발급");
      final tokenResponse = await refreshAccessToken();
      log("tokenResponse: $tokenResponse");
      if (tokenResponse) {
        log("asyncFuction을 서버에 요청 시작 - 두 번째");
        final asyncFunctionAgainResult = await asyncFuction();
        log("asyncFunctionAgainResult: $asyncFunctionAgainResult");
        if (!asyncFunctionAgainResult) {
          log("두 번째 요청 실패 - 토큰 만료");
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("로그인 만료"),
              content: const Text("다시 로그인을 해주세요."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false // 스택에 남는 페이지 없이 전체 초기화
                    );
                  },
                  child: const Text("로그인 화면으로 이동"),
                ),
              ],
            ),
          );
        } else {
          log("두 번째 요청 성공 - 토큰 재발급 성공");  
        }
      
        return asyncFunctionAgainResult;
      }

      log("accessToken 재발급 실패");
    }

    return asyncFunctionResult;
  }

  Future<bool> refreshAccessToken() async {
    String? refreshToken = await SecureStorage.getRefreshToken();
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/token-refresh");
    final headers = {'Authorization': 'Bearer $refreshToken'};

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

        log("refreshToken으로 새로운 accessToken 발급");
        return true;
      } else {
        // refreshToken이 만료되었거나 갱신 실패

        log("refreshToken이 만료되거나 갱신 실패");
        return false;
      }
    } catch (e) {
      log("네트워크 오류: ${e.toString()}");
      return false;
    }
  }
}