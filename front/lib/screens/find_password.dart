import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gachi_janchi/utils/checkValidate.dart';

class FindPassword extends StatefulWidget {
  const FindPassword({super.key});

  @override
  State<FindPassword> createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPassword> {

  // 이름 & 이메일 & 인증번호 입력 값 저장
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var codeController = TextEditingController();

  // 이름 & 이메일 & 인증번호 FocusNode
  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode codeFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 이메일 유효성 상태
  bool isEmailValid = false;

  // 인증번호 전송 상태
  bool isCodeSent = false;

  // 인증번호 유효성 상태
  bool isCodeValid = false;

  // 인증번호 확인 상태
  bool isCodeCheck = false;

  // 타이머 시간
  int remainingTime = 180; // 3분(180초)
  Timer? timer;

  // 이메일 상태를 개별적으로 검증하는 함수
  void validateEmail(String email) {
    final isValid = CheckValidate().validateEmail(emailFocus, email) == null;
    setState(() {
      isEmailValid = isValid;
    });
  }

  // 인증번호 전송 함수
  Future<void> sendVerificationCode() async {
    print("인증번호 전송");
    setState(() {
      isCodeSent = true;
    });
  }

  // 인증번호 상태를 개별적으로 검증하는 함수
  void validateCode(String code) {
    final isValid = CheckValidate().validateCode(codeFocus, code) == null && (remainingTime > 0 && remainingTime < 180);
    setState(() {
      isCodeValid = isValid;
    });
  }

  // 인증번호 확인 함수
  Future<void> checkVerificationCode() async {
    print("인증번호 확인");
    setState(() {
      isCodeCheck = true;
    });
  }

  // 타이머 시작 함수
  void startTimer() {
    
    // 기존 타이머가 있으면 취소
    timer?.cancel();

    setState(() {
      remainingTime = 180;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--; // 남은 시간 감소
        } else {
          timer.cancel(); // 타이머 취소
        }
      });
    });
  }

  // 시간 형식 변환 함수 (초 -> mm:ss)
  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    timer?.cancel(); // 화면 종료 시 타이머 취소
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Form(
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
                                  Text(
                                    "우리 가치,",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(
                                    "비밀번호를 찾아볼까요?",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container( // 이름 & 이메일 & 인증코드 입력 부분
                              child: Column(
                                children: [
                                  Container( // 이름 입력 부분
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "이름 *",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        TextFormField(
                                          controller: nameController,
                                          focusNode: nameFocus,
                                          keyboardType: TextInputType.text,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            return CheckValidate().validateName(nameFocus, value);
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "이름을 입력해주세요."
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container( // 이메일 입력 부분
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "이메일 *",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: emailController,
                                                focusNode: emailFocus,
                                                keyboardType: TextInputType.emailAddress,
                                                onChanged: validateEmail, // 입력할 때마다 이메일 유효성 검7
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: (value) {
                                                  return CheckValidate().validateEmail(emailFocus, value);
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: "이메일을 입력해주세요."
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: isEmailValid 
                                                ? () {
                                                    print("isEmailValid: ${isEmailValid}");
                                                    sendVerificationCode();
                                                    startTimer();
                                                  }
                                                : null,
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(135, 50),
                                                backgroundColor: const Color.fromRGBO(122, 11, 11, 1) ,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)
                                                )
                                              ),
                                              child: Text(
                                                isCodeSent ? "재전송" : "인증번호 전송",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              )
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container( // 인증번호 입력 부분
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "인증번호 *",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(
                                              isCodeSent ? formatTime(remainingTime) : "",
                                              style: const TextStyle(
                                                fontSize: 18
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: codeController,
                                                focusNode: codeFocus,
                                                keyboardType: TextInputType.number,
                                                maxLength: 6,
                                                onChanged: validateCode, // 입력할 때마다 인증번호 유효성 검사
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: (value) {
                                                  return CheckValidate().validateCode(codeFocus, value);
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: "인증번호를 입력해주세요."
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: isCodeValid 
                                              ? () {
                                                  checkVerificationCode();
                                                }
                                              : null,
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(135, 50),
                                                backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)
                                                )
                                              ),
                                              child: const Text(
                                                "인증번호 확인",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              )
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      print("비밀번호 찾기");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("입력 정보를 다시 확인해주세요."))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: const Text(
                    "비밀번호 찾기",
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