import 'dart:async';
import 'dart:developer';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/screens/change_password_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gachi_janchi/utils/checkValidate.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPasswordScreen> {
  Dio dio = Dio();
  late CookieJar cookieJar;
  String sessionId = "";

  // 이름 & 아이디 & 이메일 & 인증번호 입력 값 저장
  var nameController = TextEditingController();
  var idController = TextEditingController();
  var emailController = TextEditingController();
  var codeController = TextEditingController();

  // 이름 & 아이디 & 이메일 & 인증번호 FocusNode
  FocusNode nameFocus = FocusNode();
  FocusNode idFocus = FocusNode();
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

  @override
  void initState() {
    super.initState();

    // 쿠키 저장용 CookieJar 초기화
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar)); // CookieManager 추가
  }

  @override
  void dispose() {
    timer?.cancel(); // 화면 종료 시 타이머 취소
    super.dispose();

    nameController.dispose();
    idController.dispose();
    emailController.dispose();
    codeController.dispose();

    // FocusNode dispose
    nameFocus.dispose();
    idFocus.dispose();
    emailFocus.dispose();
    codeFocus.dispose();
  }

  // 이메일 상태를 개별적으로 검증하는 함수
  void validateEmail(String email) {
    final isValid = checkValidate().validateEmail(email) == null;
    setState(() {
      isEmailValid = isValid;
    });
  }

  // 인증번호 전송 함수
  Future<void> sendVerificationCode() async {
    print("인증번호 전송");

    String email = emailController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress =
        Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/email/code");

    try {
      final response = await dio.post(apiAddress.toString(),
          data: {'email': email, 'type': 'password'});

      log("response data = ${response.toString()}");

      if (response.statusCode == 200) {
        startTimer();
        // 인증번호 메일 보내기 성공 처리
        print("인증번호 보내기 성공");

        setState(() {
          if (isCodeSent && isCodeCheck) {
            isCodeCheck = false;
            print("인증번호 재전송, isCodeCheck: ${isCodeCheck}");
          }
          isCodeSent = true;
          sessionId = response.data['sessionId']; // 세션 ID 저장
        });
      } else {
        print("인증번호 보내기 실패: ${response.data}");
      }
    } catch (e) {
      // 예외 처리
      if (e is DioError) {
        log("${e.response?.toString()}");
      }
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text("인증번호 전송 오류"),
                content: Text("서버에 문제가 발생했습니다."),
              ));
    }
  }

  // 인증번호 확인 요청 함수
  Future<void> checkVerificationCode() async {
    print("인증번호 확인 요청");

    String verificationCode = codeController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress =
        Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/email/verify");

    try {
      final response = await dio.post(apiAddress.toString(),
          data: {'verificationCode': verificationCode},
          options: Options(
            headers: {'sessionId': sessionId}, // 세션 ID 헤더 추가
          ));

      log("response data = ${response.toString()}");

      if (response.statusCode == 200) {
        // 인증번호 확인 성공 처리
        print("인증번호 확인 성공");
        setState(() {
          isCodeCheck = true;
        });
      } else {
        print("인증번호 확인 실패: ${response.data}");
      }
    } catch (e) {
      // 예외 처리
      if (e is DioError) {
        log("${e.response?.toString()}");
      }
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text("인증번호 전송 오류"),
                content: Text("서버에 문제가 발생했습니다."),
              ));
    }
  }

  // 인증번호 상태를 개별적으로 검증하는 함수
  void validateCode(String code) {
    final isValid = checkValidate().validateCode(code) == null &&
        (remainingTime > 0 && remainingTime < 180);
    setState(() {
      isCodeValid = isValid;
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

  // 비밀번호 찾기 요청 함수
  Future<void> findPassword() async {
    final name = nameController.text;
    final id = idController.text;
    final email = emailController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse(
        "${dotenv.get("API_ADDRESS")}/api/auth/password?name=${name}&id=${id}&email=${email}");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers,
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        // 비밀번호 찾기 성공 처리
        print("비밀번호 찾기 요청 성공");

        final data = json.decode(response.body);

        bool isExistUser = data['existUser'];

        print("isExistUser: ${isExistUser}");

        if (isExistUser) {
          // 이름, 아이디, 이메일로 사용자를 찾은 경우 비밀번호 변경 페이지로 넘어감
          print("사용자 찾기 성공");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(
                data: {
                  "id": id,
                },
              ),
            ),
          );
        } else {
          // 사용자를 찾을 수 없는 경우 오류 메시지 발생
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("사용자를 찾을 수 없습니다. 입력값을 다시 확인해주세요.")));
        }
      } else {
        print("사용자를 찾을 수 없습니다.");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Container(
        // 전체화면
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
                            Container(
                              // 페이지 타이틀
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "우리 가치,",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "비밀번호를 찾아볼까요?",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              // 이름 & 이메일 & 인증코드 입력 부분
                              child: Column(
                                children: [
                                  Container(
                                    // 이름 입력 부분
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "이름 *",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextFormField(
                                          controller: nameController,
                                          focusNode: nameFocus,
                                          keyboardType: TextInputType.text,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            return checkValidate()
                                                .validateName(value);
                                          },
                                          decoration: const InputDecoration(
                                              hintText: "이름을 입력해주세요."),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    // 이름 입력 부분
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "아이디 *",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextFormField(
                                          controller: idController,
                                          focusNode: idFocus,
                                          keyboardType: TextInputType.text,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            return checkValidate()
                                                .validateId(value, true);
                                          },
                                          decoration: const InputDecoration(
                                              hintText: "이름을 입력해주세요."),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    // 이메일 입력 부분
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "이메일 *",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: emailController,
                                                focusNode: emailFocus,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                onChanged:
                                                    validateEmail, // 입력할 때마다 이메일 유효성 검7
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  return checkValidate()
                                                      .validateEmail(value);
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "이메일을 입력해주세요."),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                                onPressed: isEmailValid
                                                    ? () {
                                                        sendVerificationCode();
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        const Size(135, 50),
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                            122, 11, 11, 1),
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                child: Text(
                                                  isCodeSent
                                                      ? "재전송"
                                                      : "인증번호 전송",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    // 인증번호 입력 부분
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "인증번호 *",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              isCodeSent
                                                  ? formatTime(remainingTime)
                                                  : "",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: codeController,
                                                focusNode: codeFocus,
                                                keyboardType:
                                                    TextInputType.number,
                                                maxLength: 6,
                                                onChanged:
                                                    validateCode, // 입력할 때마다 인증번호 유효성 검사
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  return checkValidate()
                                                      .validateCode(value);
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "인증번호를 입력해주세요."),
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
                                                    minimumSize:
                                                        const Size(135, 50),
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                            122, 11, 11, 1),
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                child: const Text(
                                                  "인증번호 확인",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
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
                    )),
              ),
            ),
            Container(
              child: ElevatedButton(
                  onPressed: (formKey.currentState?.validate() ?? false) &&
                          isCodeSent &&
                          isCodeCheck
                      ? () {
                          print("비밀번호 찾기 버튼 클릭");
                          findPassword();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  child: const Text(
                    "비밀번호 찾기",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
            )
          ],
        ),
      )),
    );
  }
}
