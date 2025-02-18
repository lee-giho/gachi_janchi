import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/checkValidate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:gachi_janchi/utils/screen_size.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // ScreenSize 값 가져오기
  // final screenWidth = ScreenSize().width;
  // final screenHeight = ScreenSize().height;

  // 이름 & 이메일 & 아이디 & 비밀번호 & 비밀번호 확인 입력 값 저장
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var idController = TextEditingController();
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();

  // 이름 & 이메일 & 비밀번호 & 비밀번호 확인 FocusNode
  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode idFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();

  // 아이디 중복확인 여부
  bool idValid = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 아이디 중복확인 요청 함수
  Future<void> checkIdDuplication() async {
    print("아이디 중복확인");

    String id = idController.text;
    
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/duplication/id?id=${id}");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        print("아이디 중복 확인 완료");

        final data = json.decode(response.body);
        bool isDuplication = data['duplication'];

        print("isDuplication: ${isDuplication}");

        if (isDuplication) {
          setState(() {
            idValid = false;
          });

          print("idValid: ${idValid}");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("중복된 아이디입니다."))
          );
        } else {
          setState(() {
            idValid = true;
          });

          print("idValid: ${idValid}");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("사용 가능한 아이디입니다."))
          );
        }
      } else {
        print("아이디 중복 확인 실패");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("아이디 중복 확인 실패"))
        );
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  // 회원가입 함수
  Future<void> signUp() async {
    final name = nameController.text;
    final email = emailController.text;
    final id = idController.text;
    final password = passwordController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/register");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          'id': id,
          'password': password
        })
      );
      
      if (response.statusCode == 200) {
        // 회원가입 성공 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 성공"))
        );

        Navigator.pop(context);
      } else {
        // 회원가입 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입 실패: ${response.body}"))
        );
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container( // 전체 화면
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    // padding: EdgeInsets.fromLTRB(screenWidth*0.1, screenHeight*0.05, screenWidth*0.1, screenHeight*0.05),
                    // width: screenWidth,
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "잔치를 시작해 볼까요?",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container( // 이름 & 이메일 & 비밀번호 & 비밀번호 확인 입력 부분
                              child: Column(
                                children: [
                                  Container( // 이름 입력 부분
                                    // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
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
                                          onChanged: (value) {
                                            setState(() {
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "이름을 입력해주세요.",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container( // 이메일 입력 부분
                                    // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
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
                                        TextFormField(
                                          controller: emailController,
                                          focusNode: emailFocus,
                                          keyboardType: TextInputType.emailAddress,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            return CheckValidate().validateEmail(emailFocus, value);
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "이메일을 입력해주세요.",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container( // 아이디 입력 부분
                                    // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "아이디 *",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: idController,
                                                focusNode: idFocus,
                                                keyboardType: TextInputType.text,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: (value) {
                                                  return CheckValidate().validateId(idFocus, value, idValid);
                                                },
                                                onChanged: (value) {
                                                  // 아이디가 변경될 때마다 중복 확인 결과 초기화
                                                  if (idValid) {
                                                    setState(() {
                                                      idValid = false;
                                                    });
                                                  }
                                                },
                                                decoration: const InputDecoration(
                                                  hintText: "아이디를 입력해주세요.",
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                checkIdDuplication();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(100, 50),
                                                backgroundColor: const Color.fromRGBO(122, 11, 11, 1) ,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)
                                                )
                                              ),
                                              child: const Text(
                                                "중복확인",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              )
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                                            return CheckValidate().validatePassword(passwordFocus, value);
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                            });
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
                                            return CheckValidate().validateRePassword(rePasswordFocus, passwordController.text, value);
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                            });
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    // onPressed: () {
                    //   if (formKey.currentState!.validate()) {
                    //     // ScaffoldMessenger.of(context).showSnackBar(
                    //     //   SnackBar(content: Text("폼이 유효합니다."))
                    //     // );
                    //     signUp();
                    //     Navigator.pop(context);
                    //   } else {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text("입력 정보를 다시 확인해주세요."))
                    //     );
                    //   }
                    // },
                    onPressed: (formKey.currentState?.validate() ?? false) && idValid
                    ? () {
                        signUp();
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
                      "회원가입",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}