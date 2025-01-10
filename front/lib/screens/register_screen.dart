import 'package:flutter/material.dart';
import 'package:gachi_janchi/utils/screen_size.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // ScreenSize 값 가져오기
  final screenWidth = ScreenSize().width;
  final screenHeight = ScreenSize().height;

  // 이름 & 이메일 & 비밀번호 & 비밀번호 확인 입력 값 저장
  var name = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  var rePassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(screenWidth*0.1, screenHeight*0.05, screenWidth*0.1, screenHeight*0.05),
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container( // 페이지 타이틀
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
                      margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
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
                          TextField(
                            controller: name,
                            decoration: const InputDecoration(
                              hintText: "이름을 입력해주세요.",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container( // 이메일 입력 부분
                      margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
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
                          TextField(
                            controller: email,
                            decoration: const InputDecoration(
                              hintText: "이메일을 입력해주세요.",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container( // 비밀번호 입력 부분
                      margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
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
                          TextField(
                            controller: password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "비밀번호를 입력해주세요.",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container( // 비밀번호 확인 입력 부분
                      margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
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
                          TextField(
                            controller: rePassword,
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
              Container(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth*0.8, 50),
                    backgroundColor: Color.fromRGBO(122, 11, 11, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: Text(
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
        )
      )
    );
  }
}