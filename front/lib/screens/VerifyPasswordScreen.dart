import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';
import 'edit_password_screen.dart'; // ✅ 새로운 비밀번호 입력 화면

class VerifyPasswordScreen extends StatefulWidget {
  const VerifyPasswordScreen({super.key});

  @override
  State<VerifyPasswordScreen> createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends State<VerifyPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordEntered = false; // ✅ 입력 상태 확인

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  /// ✅ 현재 비밀번호 검증 요청
  Future<void> verifyCurrentPassword() async {
    String password = passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("비밀번호를 입력해주세요.")));
      return;
    }

    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    final apiAddress =
        Uri.parse("http://localhost:8080/api/user/verify-password");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };
    final body = {'password': password};

    try {
      setState(() => _isLoading = true);

      var dio = Dio();
      final response = await dio.post(apiAddress.toString(),
          options: Options(headers: headers), data: body);

      print("🔹 [API 응답] 상태 코드: ${response.statusCode}");
      print("🔹 [API 응답 데이터]: ${response.data}");

      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is bool) {
          // ✅ 서버 응답이 true/false인지 확인
          if (responseData) {
            print("✅ 비밀번호 확인 성공! 비밀번호 변경 화면으로 이동");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditpasswordScreen()));
          } else {
            print("❌ 비밀번호가 일치하지 않습니다.");
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")));
          }
        } else {
          print("❌ 서버 응답 구조가 예상과 다릅니다: $responseData");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("서버 오류: 응답이 올바르지 않습니다.")));
        }
      }
    } on DioException catch (e) {
      print("❌ [Dio 오류] ${e.message}");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.message}")));
    } catch (e) {
      print("❌ [예외 발생] $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("현재 비밀번호 확인")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "현재 비밀번호를 입력해주세요.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _isPasswordEntered = value.isNotEmpty;
                });
              },
              onFieldSubmitted: (_) =>
                  verifyCurrentPassword(), // ✅ Enter 키 입력 시 실행
              decoration: const InputDecoration(
                hintText: "현재 비밀번호 입력",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: (_isLoading || !_isPasswordEntered)
                    ? null
                    : verifyCurrentPassword,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("확인", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
