import 'package:flutter/material.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/checkValidate.dart';

class EditpasswordScreen extends StatefulWidget {
  const EditpasswordScreen({super.key});

  @override
  State<EditpasswordScreen> createState() => _EditpasswordScreenState();
}

class _EditpasswordScreenState extends State<EditpasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool isNewPasswordValid = false;
  bool isConfirmPasswordValid = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // 비밀번호 변경 요청 (새 비밀번호만 전송)
  Future<bool> changePassword({bool isFinalRequest = false}) async {
    if (!isNewPasswordValid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("비밀번호를 확인해주세요.")));
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("새 비밀번호가 일치하지 않습니다.")));
      return false;
    }

    print("비밀번호 변경 요청 시작");

    String newPassword = newPasswordController.text.trim();
    String? accessToken = await SecureStorage.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return false;
    }

    final apiAddress = Uri.parse(
        "${dotenv.get("API_ADDRESS")}/api/user/password"); // 비밀번호 변경 API 주소
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };
    final body = json.encode({
      'password': newPassword, // 현재 비밀번호 없이 새 비밀번호만 전송
    });

    try {
      setState(() {
        _isLoading = true;
      });

      final response =
          await http.patch(apiAddress, headers: headers, body: body);

      print("서버 응답 코드: ${response.statusCode}");
      print("서버 응답 데이터: ${response.body}");

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData["success"] == true) {
        print("비밀번호 변경 성공");
        return true;
      } else {
        print("비밀번호 변경 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("비밀번호 변경")),
      body: SafeArea(
        child: Container( // 전체 화면
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "새로운 비밀번호를 입력해주세요.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return checkValidate().validatePassword(value);
                        },
                        onChanged: (value) {
                          setState(() {
                            isNewPasswordValid =
                                checkValidate().validatePassword(value) == null;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "새 비밀번호 입력",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          return checkValidate()
                              .validateRePassword(newPasswordController.text, value);
                        },
                        onChanged: (value) {
                          setState(() {
                            isConfirmPasswordValid = checkValidate().validateRePassword(
                                    newPasswordController.text, value) ==
                                null;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "새 비밀번호 확인",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: (_isLoading ||
                          !isNewPasswordValid ||
                          !isConfirmPasswordValid)
                      ? null
                      : () async {
                        final result = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => changePassword(isFinalRequest: isFinalRequest), context);
                        if (result) {
                          ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")));
                          Navigator.pop(context); // 변경 성공 후 화면 닫기
                        } else {
                          ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("비밀번호 변경에 실패했습니다.")));
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
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
      ),
    );
  }
}
