import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secure_storage.dart';
import '../utils/checkValidate.dart'; // ✅ CheckValidate 추가
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'mypage_screen.dart'; // ✅ 마이페이지로 돌아가기 위해 추가

class EditemailScreen extends StatefulWidget {
  final String currentValue;

  const EditemailScreen({super.key, required this.currentValue});

  @override
  State<EditemailScreen> createState() => _EditemailScreenState();
}

class _EditemailScreenState extends State<EditemailScreen> {
  late TextEditingController controller;
  bool _isLoading = false;
  String? _emailError; // ✅ 이메일 형식 검사 결과 저장

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// ✅ 서버에 이메일 저장 요청 (`http` 사용)
  Future<void> saveEmail() async {
    print("이메일 저장 요청 시작");

    String email = controller.text.trim();
    String? accessToken = await SecureStorage.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/email");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };
    final body = json.encode({'email': email});

    print("🔹 서버로 전송할 데이터: $body");

    try {
      setState(() {
        _isLoading = true;
      });

      final response =
          await http.patch(apiAddress, headers: headers, body: body);

      print("🔹 서버 응답 코드: ${response.statusCode}");
      print("🔹 서버 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ 이메일 저장 성공");
        Navigator.pop(context, email);
      } else {
        print("❌ 이메일 저장 실패");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("이메일 저장에 실패했습니다. 입력 정보를 다시 확인해주세요.")));
      }
    } catch (e) {
      print("❌ 네트워크 오류 발생: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("이메일 변경"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "새로운 이메일을 입력해주세요.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ 이메일 입력 필드 (CheckValidate 사용)
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: "새로운 이메일 입력",
                border: const UnderlineInputBorder(),
                errorText: _emailError, // ✅ 오류 메시지 표시
              ),
              onChanged: (value) {
                setState(() {
                  _emailError = CheckValidate().validateEmail(value);
                });
              },
            ),
            const SizedBox(height: 30),

            // ✅ 변경 완료 버튼 (이메일 형식이 맞아야 활성화)
            Center(
              child: ElevatedButton(
                onPressed:
                    (_isLoading || _emailError != null) ? null : saveEmail,
                child: const Text("변경 완료"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
