import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'mypage_screen.dart'; // 마이페이지로 돌아가기 위해 추가

class EditnicknameScreen extends StatefulWidget {
  final String currentValue;

  const EditnicknameScreen({super.key, required this.currentValue});

  @override
  State<EditnicknameScreen> createState() => _EditnicknameScreenState();
}

class _EditnicknameScreenState extends State<EditnicknameScreen> {
  late TextEditingController controller;
  bool _isLoading = false; // 로딩 상태 추가

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

  /// 서버에 nickname 저장 요청 (`http` 사용)
  Future<void> saveNickName() async {
    print("닉네임 저장 요청 시작");

    String nickName = controller.text.trim();
    String? accessToken = await SecureStorage.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    final apiAddress =
        Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/nick-name");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };
    final body = json.encode({'nickName': nickName});

    print("🔹 서버로 전송할 데이터: $body"); // 디버깅용 출력

    try {
      setState(() {
        _isLoading = true; // 로딩 시작
      });

      final response =
          await http.patch(apiAddress, headers: headers, body: body);

      print("🔹 서버 응답 코드: ${response.statusCode}");
      print("🔹 서버 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        print("닉네임 저장 성공");

        // ✅ 닉네임 저장 성공 후 마이페이지로 돌아가기
        Navigator.pop(context, nickName); // 🔹 변경된 닉네임을 이전 화면으로 전달
      } else {
        print("닉네임 저장 실패");

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("닉네임 저장에 실패했습니다. 입력 정보를 다시 확인해주세요.")));
      }
    } catch (e) {
      print("네트워크 오류 발생: $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("닉네임 변경"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 🔹 뒤로가기 (변경 없이 취소)
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
              "용사님의 새로운 이름을 알려주세요.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: "새로운 닉네임 입력",
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : saveNickName,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("변경 완료", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
