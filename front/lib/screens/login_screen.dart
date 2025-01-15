import 'package:flutter/material.dart';
import 'package:gachi_janchi/screens/register_screen.dart';
// import '../utils/screen_size.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // ScreenSize 값 가져오기
  // final screenWidth = ScreenSize().width;
  // final screenHeight = ScreenSize().height;

  // 아이디 & 비밀번호 입력 값 저장
  var id = TextEditingController();
  var password = TextEditingController();

  bool? _isAutoLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: EdgeInsets.fromLTRB(screenWidth*0.1, 0, screenWidth*0.1, 0),
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          // width: screenWidth,
          child: Column(
            children: [
              Container( // 로고
                // margin: EdgeInsets.fromLTRB(0, screenHeight*0.05, 0, screenHeight*0.05),
                margin: const EdgeInsets.fromLTRB(0, 50, 0, 30),
                child: Image.asset(
                  'assets/images/gachi_janchi_logo.png',
                  fit: BoxFit.contain,
                  // height: screenHeight*0.15,
                  height: 150,
                ),
              ),
              Container( // 로그인폼 부분
                child: Column(
                  children: [
                    Container( // 아이디 & 비밀번호 입력 부분
                      child: Column(
                        children: [
                          Container( // 아이디 입력 부분
                            // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "아이디",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                TextField(
                                  controller: id,
                                  decoration: const InputDecoration(
                                    hintText: "아이디를 입력해주세요.",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(color: Color.fromRGBO(121, 55, 64, 0.612))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(color: Color.fromRGBO(122, 11, 11, 1))
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container( // 비밀번호 입력 부분
                            // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "비밀번호",
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
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(color: Color.fromRGBO(121, 55, 64, 0.612))
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(color: Color.fromRGBO(122, 11, 11, 1))
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container( // 로그인 버튼 부분
                      // margin: EdgeInsets.fromLTRB(0, screenHeight*0.01, 0, 0),
                      child: Column(
                        children: [
                          Container( // 로그인 상태 유지 체크박스 부분
                            child: Row(
                              children: [
                                Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  value: _isAutoLogin,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAutoLogin = value;
                                    });
                                  }
                                ),
                                const Text(
                                  "로그인 상태 유지",
                                  style: TextStyle(
                                    fontSize: 18
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container( // 로그인 버튼
                            // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                            child: ElevatedButton(
                              onPressed: () {
                                print("id: ${id.text}");
                                print("password: ${password.text}");
                              },
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
                                "로그인",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "비밀번호 찾기",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 41, 41, 41)
                                  ),
                                ),
                              ),
                              const Text("|"),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "아이디 찾기",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 41, 41, 41)
                                  ),
                                ),
                              ),
                              const Text("|"),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen())
                                  );
                                },
                                child: const Text(
                                  "회원가입",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 41, 41, 41)
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container( // 소셜로그인 부분
                      // margin: EdgeInsets.fromLTRB(0, screenHeight*0.02, 0, 0),
                      height: 200,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container( // 구글 로그인
                            // width: screenWidth*0.7,
                            height: 40,
                            // margin: EdgeInsets.fromLTRB(0, screenHeight*0.02, 0, 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text("구글로 로그인")
                            ),
                          ),
                          Container( // 네이버 로그인
                            // width: screenWidth*0.7,
                            height: 40,
                            // margin: EdgeInsets.fromLTRB(0, screenHeight*0.02, 0, 0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(
                                color: Colors.black,
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text("네이버로 로그인")
                            ),
                          ),
                          Container( // 카카오 로그인
                            // width: screenWidth*0.7,
                            height: 40,
                            // margin: EdgeInsets.fromLTRB(0, screenHeight*0.02, 0, 0),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              border: Border.all(
                                color: Colors.black,
                                width: 1
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text("카카오로 로그인")
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}