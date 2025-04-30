import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/checkValidate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

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

  // 상태값 추가
  bool isNameValid = false;
  bool isEmailValid = false;
  bool isIdValid = false;
  bool isPasswordValid = false;
  bool isRePasswordValid = false;

  // 아이디 중복확인 여부
  bool idValid = false;

  // 아이디 입력 검증
  bool idInputValid = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();

    nameController.dispose();
    emailController.dispose();
    idController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();

    nameFocus.dispose();
    emailFocus.dispose();
    idFocus.dispose();
    passwordFocus.dispose();
    rePasswordFocus.dispose();
  }

  // 입력 상태 체크 함수
  void checkFormValid() {
    setState(() {
      isNameValid = checkValidate().validateName(nameController.text) == null;
      isEmailValid = checkValidate().validateEmail(emailController.text) == null;
      isIdValid = checkValidate().validateId(idController.text, idValid) == null;
      isPasswordValid = checkValidate().validatePassword(passwordController.text) == null;
      isRePasswordValid = checkValidate().validateRePassword(passwordController.text, rePasswordController.text) == null;
    });
  }

  // 회원가입 버튼 활성화 조건
  bool get isFormValid {
    return isNameValid && isEmailValid && isIdValid && isPasswordValid && isRePasswordValid && idValid;
  }

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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Form(
            key: formKey,
            child: Container( // 전체 화면
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
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
                                              return checkValidate().validateName(value);
                                            },
                                            onChanged: (value) {
                                              checkFormValid();
                                            },
                                            decoration: const InputDecoration(
                                              hintText: "이름을 입력해주세요.",
                                            ),
                                          ),
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
                                          TextFormField(
                                            controller: emailController,
                                            focusNode: emailFocus,
                                            keyboardType: TextInputType.emailAddress,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            validator: (value) {
                                              return checkValidate().validateEmail(value);
                                            },
                                            onChanged: (value) {
                                              checkFormValid();
                                            },
                                            decoration: const InputDecoration(
                                              hintText: "이메일을 입력해주세요.",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container( // 아이디 입력 부분
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
                                                    return checkValidate().validateId(value, idValid);
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      idInputValid = checkValidate().checkIdInput(value);  
                                                    });
                                                    
                                                    isIdValid = checkValidate().validateId(value, idValid) == null;
                                                    idValid = false; // 값이 변경되면 중복확인 필요
                                                  },
                                                  decoration: const InputDecoration(
                                                    hintText: "아이디를 입력해주세요.",
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: idInputValid
                                                ? () {
                                                    checkIdDuplication();
                                                    setState(() {
                                                      idValid = true;
                                                    });
                                                  }
                                                : null,
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
                                              return checkValidate().validatePassword(value);
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
                                              return checkValidate().validateRePassword(passwordController.text, value);
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: isFormValid
                      ? () {
                          signUp();
                        }
                      : null,
                      style: ElevatedButton.styleFrom(
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
          ),
        )
      )
    );
  }
}