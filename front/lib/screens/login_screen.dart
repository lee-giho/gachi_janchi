import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:gachi_janchi/screens/find_password_screen.dart';
import 'package:gachi_janchi/screens/home_screen.dart';
import 'package:gachi_janchi/screens/main_screen.dart';
import 'package:gachi_janchi/screens/nickName_registration_screen.dart';
import 'package:gachi_janchi/screens/test_screen.dart';
import 'package:gachi_janchi/screens/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';
import '../utils/secure_storage.dart';
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

  bool? isAutoLogin = false;

  // 아이디 & 비밀번호 입력 값 저장
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  // 아이디 & 비밀번호 FocusNode
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 자동로그인 상태 저장 함수
  void saveIsAutoLogin(bool? isAutoLogin) async {
    // 토큰을 secure_storage에 저장
    await SecureStorage.saveIsAutoLogin(isAutoLogin);
  }

  // 로그인 함수
  Future<void> login() async {
    print("로그인 요청");

    String email = emailController.text;
    String password = passwordController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login");
    final headers = {'Content-Type': 'application/json'};

    try {
      print("로그인 요청 보내기 시작");
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password
        })
      );

      if (response.statusCode == 200) {
        // 로그인 성공 처리
        final data = json.decode(response.body);
        print(data);
        String accessToken = data['accessToken'];
        String refreshToken = data['refreshToken'];
        print("여기까지");
        bool existNickName = data['existNickName'];

        // 토큰을 secure_storage에 저장
        await SecureStorage.saveAccessToken(accessToken);
        await SecureStorage.saveRefreshToken(refreshToken);

        print("isexistNickName: ${existNickName}");

        if (existNickName) {
          // 로그인 성공 후 닉네임이 있을 경우, 메인 화면으로 이동
          Navigator.pushReplacement(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const MainScreen())
          );
        } else {
          // 로그인 성공 후 닉네임이 없을 경우, 닉네임 등록 화면으로 이동
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const NicknameRegistrationScreen())
          );
        }

        
      } else {
        // 로그인 실패 처리
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("로그인 실패"),
            content: Text("아이디 또는 비밀번호를 확인해주세요."),
          )
        );
      }
    } catch (e) {
      // 예외 처리
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("로그인 오류"),
          content: Text("서버에 문제가 발생했습니다."),
        )
      );
    }
  }

  

  Future<void> handleGoogleSignIn() async {
    try {
      print("구글 로그인 클릭");
      // 구글 로그인
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      print("googleSignIn: ${googleSignIn}");

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      print("account: ${account}");

      if (account == null) {
        print("구글 로그인 취소됨");
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      print("auth: ${auth.toString()}");


      final String? idToken = auth.idToken;

      print("idToken: ${idToken}");

      if (idToken == null) {
        print("idToken 획득 실패");
        return;
      }

      // .env에서 서버 URL 가져오기
      final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login/google");
      final headers = {'Content-Type': 'application/json'};
      
      // Spring boot로 idToken 전달
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          'idToken': idToken
        })
      );

      if (response.statusCode == 200) {
        print("구글 로그인 성공");
        // 로그인 성공 처리
        final data = json.decode(response.body);
        String accessToken = data['accessToken'];
        String refreshToken = data['refreshToken'];
        bool existNickName = data['existNickName'];

        // 토큰을 secure_storage에 저장
        await SecureStorage.saveAccessToken(accessToken);
        await SecureStorage.saveRefreshToken(refreshToken);

        // 로그인 타입 저장
        await SecureStorage.saveLoginType("google");

        print("existNickName: ${existNickName}");

        if (existNickName) {
          // 로그인 성공 후 닉네임이 있을 경우, 메인 화면으로 이동
          Navigator.pushReplacement(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const MainScreen())
          );
        } else {
          // 로그인 성공 후 닉네임이 없을 경우, 닉네임 등록 화면으로 이동
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const NicknameRegistrationScreen())
          );
        }
      } else {
        print("구글 로그인 실패");
      }
    } catch (e) {
      print("구글 로그인 중 오류 발생: $e");
    }
  }

  // 네이버 로그인
  Future<void> handleNaverSignIn() async {
    try {
      // 1. 로그인 (토큰 가져오기)
      await FlutterNaverLogin.logIn(); // 네이버 로그인 시도
      NaverAccessToken token = await FlutterNaverLogin.currentAccessToken; // 토큰 가져오기
      print("네이버 로그인 성공: ${token.accessToken}");

      // // .env에서 서버 URL 가져오기
      final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login/naver");
      final headers = {'Content-Type': 'application/json'};

      // Spring boot로 token 전달
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          'accessToken': token.accessToken
        })
      );

      if (response.statusCode == 200) {
        print("네이버 로그인 성공");
        // 로그인 성공 처리
        final data = json.decode(response.body);
        String accessToken = data['accessToken'];
        String refreshToken = data['refreshToken'];
        bool existNickName = data['existNickName'];

        // 토큰을 secure_storage에 저장
        await SecureStorage.saveAccessToken(accessToken);
        await SecureStorage.saveRefreshToken(refreshToken);

        // 로그인 타입 저장
        await SecureStorage.saveLoginType("naver");

        if (existNickName) {
          // 로그인 성공 후 닉네임이 있을 경우, 메인 화면으로 이동
          Navigator.pushReplacement(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const MainScreen())
          );
        } else {
          // 로그인 성공 후 닉네임이 없을 경우, 닉네임 등록 화면으로 이동
          Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const NicknameRegistrationScreen())
          );
        }
      }

      
    } catch (e) {
      print("네이버 로그인 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
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
                    Form( // 아이디 & 비밀번호 입력 부분
                      key: formKey,
                      child: Column(
                        children: [
                          Container( // 아이디 입력 부분
                            // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "이메일",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                TextFormField(
                                  controller: emailController,
                                  focusNode: emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode: AutovalidateMode.onUnfocus,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "이메일을 입력해주세요.";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "이메일을 입력해주세요.",
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
                                TextFormField(
                                  controller: passwordController,
                                  focusNode: passwordFocus,
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  autovalidateMode: AutovalidateMode.onUnfocus,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "비밀번호를 입력해주세요.";
                                    } else {
                                      return null;
                                    }
                                  },
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
                                  value: isAutoLogin,
                                  onChanged: (value) {
                                    setState(() {
                                      isAutoLogin = value;
                                    });
                                    saveIsAutoLogin(isAutoLogin);
                                    print("isAutoLogin: ${isAutoLogin}");
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
                                if (formKey.currentState!.validate()) {
                                  print("id: ${emailController.text}");
                                  print("password: ${passwordController.text}");
                                  login();
                                }        
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TestScreen())
                                  );
                                },
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
                                    MaterialPageRoute(builder: (context) => const FindPassword())
                                  );
                                },
                                child: const Text(
                                  "비밀번호 찾기",
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
                          Container( // 구글 로그인 버튼
                            // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                            child: ElevatedButton(
                              onPressed: () {
                                handleGoogleSignIn();
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
                                "구글",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ),
                          ),
                          // Container( // 구글 로그인
                          //   // width: screenWidth*0.7,
                          //   height: 40,
                          //   // margin: EdgeInsets.fromLTRB(0, screenHeight*0.02, 0, 0),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     border: Border.all(
                          //       color: Colors.black,
                          //       width: 1
                          //     ),
                          //     borderRadius: BorderRadius.circular(5),
                          //   ),
                          //   child: const Center(
                          //     child: Text("구글로 로그인")
                          //   ),
                          // ),
                          Container( // 네이버 로그인 버튼
                            // margin: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.01),
                            child: ElevatedButton(
                              onPressed: () {
                                handleNaverSignIn();
                              },
                              style: ElevatedButton.styleFrom(
                                // minimumSize: Size(screenWidth*0.8, 50),
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color.fromARGB(255, 0, 182, 67),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                                )
                              ),
                              child: const Text(
                                "네이버",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ),
                          ),
                          // Container( // 네이버 로그인
                          //   // width: screenWidth*0.7,
                          //   height: 40,
                          //   // margin: EdgeInsets.fromLTRB(0, screenHeight*0.02, 0, 0),
                          //   decoration: BoxDecoration(
                          //     color: Colors.green,
                          //     border: Border.all(
                          //       color: Colors.black,
                          //       width: 1
                          //     ),
                          //     borderRadius: BorderRadius.circular(5),
                          //   ),
                          //   child: const Center(
                          //     child: Text("네이버로 로그인")
                          //   ),
                          // ),
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
                              child: Text("테스트 화면 들어가기 확인 수정 pull")
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