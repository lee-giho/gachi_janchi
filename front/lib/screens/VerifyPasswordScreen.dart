import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import '../utils/secure_storage.dart';
import 'edit_password_screen.dart'; // 새로운 비밀번호 입력 화면
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VerifyPasswordScreen extends StatefulWidget {
  const VerifyPasswordScreen({super.key});

  @override
  State<VerifyPasswordScreen> createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends State<VerifyPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordEntered = false; // 입력 상태 확인
  bool _isPasswordValid = false; // 맞는 비밀번호를 입력했는지

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  // 현재 비밀번호 검증 요청
  Future<bool> verifyCurrentPassword({bool isFinalRequest = false}) async {
    String password = passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("비밀번호를 입력해주세요.")));
      return false;
    }

    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return false;
    }

    final apiAddress =
        Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/verify-password");
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

      print("[API 응답] 상태 코드: ${response.statusCode}");
      print("[API 응답 데이터]: ${response.data}");

      if (response.statusCode == 200) {
        var responseData = response.data;

        if (responseData is bool) {
          // 서버 응답이 true/false인지 확인
          if (responseData) {
            print("비밀번호 확인 성공! 비밀번호 변경 화면으로 이동");
            setState(() {
              _isPasswordValid = true;
            });
          } else {
            print("비밀번호가 일치하지 않습니다.");
            setState(() {
              _isPasswordValid = false;
            });
          }
          return true;
        } else {
          print("서버 응답 구조가 예상과 다릅니다: $responseData");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("서버 오류: 응답이 올바르지 않습니다.")));
          return false;
        }
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (isFinalRequest) {
        print("[Dio 오류] ${e.message}");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.message}")));
      }
      return false;
    } catch (e) {
      if (isFinalRequest) {
        print("[예외 발생] $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
      }
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("현재 비밀번호 확인")),
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
                        onFieldSubmitted: (_) async {
                            final result = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => verifyCurrentPassword(isFinalRequest: isFinalRequest), context);
                            if (result) {
                              if (_isPasswordValid) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditpasswordScreen()
                                  )
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")));
                              }
                            } else {
                              ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "비밀번호 확인 실패"
                                    )
                                  )
                                );
                            }
                          },
                        decoration: const InputDecoration(
                          hintText: "현재 비밀번호 입력",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isPasswordEntered)
                    ? null
                    : () async {
                      final result = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => verifyCurrentPassword(isFinalRequest: isFinalRequest), context);
                      if (result) {
                        if (_isPasswordValid) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditpasswordScreen()
                            )
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")));
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "비밀번호 확인 실패"
                              )
                            )
                          );
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
                      : const Text("확인", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
