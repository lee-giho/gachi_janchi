import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditnameScreen extends StatefulWidget {
  final String currentValue;

  const EditnameScreen({super.key, required this.currentValue});

  @override
  State<EditnameScreen> createState() => _EditnameScreenState();
}

class _EditnameScreenState extends State<EditnameScreen> {
  late TextEditingController controller;
  bool _isLoading = false;

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

  /// 서버에 이름 저장 요청 (`http` 사용)
  Future<void> saveName() async {
    print("이름 저장 요청 시작");

    String name = controller.text.trim();
    String? accessToken = await SecureStorage.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/name");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };
    final body = json.encode({'name': name});

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
        print("이름 저장 성공");
        Navigator.pop(context, name);
      } else {
        print("이름 저장 실패");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("이름 저장에 실패했습니다. 입력 정보를 다시 확인해주세요.")));
      }
    } catch (e) {
      print("네트워크 오류 발생: $e");
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
        title: const Text("이름 변경"),
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
              "용사님의 새로운 이름을 알려주세요.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: "새로운 이름 입력",
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
                onPressed: _isLoading ? null : saveName,
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
