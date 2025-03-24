import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/checkValidate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const ChangePasswordScreen({super.key, required this.data});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  // 비밀번호 & 비밀번호 확인 입력 값 저장
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();

  // 비밀번호 & 비밀번호 확인 FocusNode
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();

  // 상태값 추가
  bool isPasswordValid = false;
  bool isRePasswordValid = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    passwordFocus.dispose();
    rePasswordFocus.dispose();
  }

  // 비밀번호 변경 요청 함수
  Future<void> changePassword() async {
    print("비밀번호 변경 요청");

    String password = passwordController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/password");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.patch(
        apiAddress,
        headers: headers,
        body: json.encode({
          'id': widget.data['id'],
          'password': password
        })
      );

      if (response.statusCode == 200) {
        // 비밀번호 변경 성공 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호 변경 완료"))
        );

        Navigator.pop(context);
      } else {
        // 비밀번호 변경 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("비밀번호 변경 실패: ${response.body}"))
        );
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  // 입력 상태 체크 함수
  void checkFormValid() {
    setState(() {
      isPasswordValid = CheckValidate().validatePassword(passwordController.text) == null;
      isRePasswordValid = CheckValidate().validateRePassword(passwordController.text, rePasswordController.text) == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container( // 페이지 타이틀
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   widget.data['id'],
                                  //   style: TextStyle(
                                  //     fontSize: 30,
                                  //     fontWeight: FontWeight.bold
                                  //   ),
                                  // ),
                                  Text(
                                    "우리 가치,",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "비밀번호를 변경해볼까요?",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container( // 비밀번호, 비밀번호 확인 입력 부분
                              child: Column(
                                children: [
                                  Container( // 비밀번호 입력 부분
                                      // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "비밀번호 *",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          TextFormField(
                                            controller: passwordController,
                                            focusNode: passwordFocus,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            validator: (value) {
                                              return CheckValidate().validatePassword(value);
                                            },
                                            onChanged: (value) {
                                              checkFormValid();
                                            },
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              hintText: "비밀번호를 입력해주세요.",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container( // 비밀번호 확인 입력 부분
                                      // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "비밀번호 확인 *",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          TextFormField(
                                            controller: rePasswordController,
                                            focusNode: rePasswordFocus,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            validator: (value) {
                                              return CheckValidate().validateRePassword(passwordController.text, value);
                                            },
                                            onChanged: (value) {
                                              checkFormValid();
                                            },
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              hintText: "비밀번호를 한 번 더 입력해주세요.",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ),
                )
              ),
              Container(
                    child: ElevatedButton(
                      onPressed: formKey.currentState?.validate() ?? false
                      ? () {
                          print("비밀번호 변경 버튼 클릭");
                          changePassword();
                        }
                      : null,
                      style: ElevatedButton.styleFrom(
                        // minimumSize: Size(screenWidth*0.8, 50),
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),
                      child: const Text(
                        "비밀번호 변경",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                  )
            ],
          ),
        )
      ),
    );
  }
}