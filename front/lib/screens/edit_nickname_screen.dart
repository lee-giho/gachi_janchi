import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/checkValidate.dart';
import 'mypage_screen.dart'; // ✅ 마이페이지로 돌아가기 위해 추가

class EditnicknameScreen extends StatefulWidget {
  final String currentValue;

  const EditnicknameScreen({super.key, required this.currentValue});

  @override
  State<EditnicknameScreen> createState() => _EditnicknameScreenState();
}

class _EditnicknameScreenState extends State<EditnicknameScreen> {
  late TextEditingController controller;
  bool _isLoading = false;
  bool _isNickNameValid = false; // ✅ 닉네임 중복 확인 여부
  bool _isDuplicateChecked = false; // ✅ 중복 확인을 했는지 여부

  @override
  void initState() {
    super.initState();
    controller =
        TextEditingController(text: widget.currentValue); // ✅ 기존 닉네임 설정
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// ✅ 닉네임 중복 확인 요청
  Future<void> checkNickNameDuplication() async {
    print("닉네임 중복 확인 요청 시작");

    String nickName = controller.text.trim();
    if (nickName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("닉네임을 입력해주세요.")));
      return;
    }

    final apiAddress = Uri.parse(
        "${dotenv.get("API_ADDRESS")}/api/user/duplication/nick-name?nickName=$nickName");

    final headers = {
      'Authorization':
          'Bearer ${await SecureStorage.getAccessToken()}', // ✅ JWT 토큰 추가
      'Content-Type': 'application/json'
    };

    print("🔹 서버 요청 URL: $apiAddress");
    print("🔹 보낸 닉네임: $nickName");

    try {
      final response = await http.get(apiAddress, headers: headers);

      print("🔹 서버 응답 코드: ${response.statusCode}");
      print("🔹 서버 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool isDuplicated = data["duplication"] ?? true;

        if (isDuplicated) {
          print("❌ 중복된 닉네임");
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("중복된 닉네임입니다.")));

          setState(() {
            _isNickNameValid = false;
            _isDuplicateChecked = true;
          });
        } else {
          print("✅ 사용 가능한 닉네임");
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("사용 가능한 닉네임입니다.")));

          setState(() {
            _isNickNameValid = true;
            _isDuplicateChecked = true;
          });
        }
      } else {
        print("❌ 닉네임 중복 확인 실패: ${response.statusCode}");
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("닉네임 중복 확인 실패")));
      }
    } catch (e) {
      print("❌ 네트워크 오류 발생: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    }
  }

  /// ✅ 서버에 닉네임 저장 요청
  Future<void> saveNickName() async {
    if (!_isNickNameValid || !_isDuplicateChecked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("닉네임 중복 확인을 해주세요.")));
      return;
    }

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

    try {
      setState(() {
        _isLoading = true;
      });

      final response =
          await http.patch(apiAddress, headers: headers, body: body);

      print("🔹 서버 응답 코드: ${response.statusCode}");
      print("🔹 서버 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ 닉네임 저장 성공");
        Navigator.pop(context, nickName);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("닉네임 저장에 실패했습니다.")));
      }
    } catch (e) {
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
              "잔치를 여실 용사님의 새로운 이름을 알려주세요.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ 닉네임 입력 필드 + 중복 확인 버튼 추가
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      return CheckValidate()
                          .validateNickName(value, _isNickNameValid);
                    },
                    onChanged: (value) {
                      if (_isDuplicateChecked) {
                        setState(() {
                          _isNickNameValid = false;
                          _isDuplicateChecked = false;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "새로운 닉네임 입력",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: checkNickNameDuplication,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  child: const Text(
                    "중복확인",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ✅ 변경 완료 버튼 (닉네임 중복 확인 후 활성화)
            Center(
              child: ElevatedButton(
                onPressed:
                    (_isLoading || !_isNickNameValid || !_isDuplicateChecked)
                        ? null
                        : saveNickName,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("변경 완료"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
