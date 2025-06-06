import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/screens/find_id_screen.dart';
import 'package:gachi_janchi/screens/find_password_screen.dart';
import 'package:gachi_janchi/screens/main_screen.dart';
import 'package:gachi_janchi/screens/nickName_registration_screen.dart';
import 'package:gachi_janchi/screens/register_screen.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool? isAutoLogin = false;

  // 아이디 & 비밀번호 입력 값 저장
  var idController = TextEditingController();
  var passwordController = TextEditingController();

  // 아이디 & 비밀번호 FocusNode
  FocusNode idFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    passwordController.dispose();
    idFocus.dispose();
    passwordFocus.dispose();
  }

  // 자동로그인 상태 저장 함수
  void saveIsAutoLogin(bool? isAutoLogin) async {
    // 토큰을 secure_storage에 저장
    await SecureStorage.saveIsAutoLogin(isAutoLogin);
  }

  // 로그인 함수
  Future<void> login() async {
    print("로그인 요청");

    String id = idController.text;
    String password = passwordController.text;

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login");
    final headers = {'Content-Type': 'application/json'};

    try {
      print("로그인 요청 보내기 시작");
      final response = await http.post(apiAddress,
          headers: headers,
          body: json.encode({'id': id, 'password': password}));

      log("response data = ${utf8.decode(response.bodyBytes)}");

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

        // 즐겨찾기 목록 불러오기
        final container = ProviderContainer();
        await ServerRequest().serverRequest(({bool isFinalRequest = false}) => container.read(favoriteProvider.notifier).fetchFavoriteRestaurants(isFinalRequest: isFinalRequest), context);

        print("isexistNickName: ${existNickName}");

        if (existNickName) {
          // 로그인 성공 후 닉네임이 있을 경우, 메인 화면으로 이동
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          // 로그인 성공 후 닉네임이 없을 경우, 닉네임 등록 화면으로 이동
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NicknameRegistrationScreen()));
        }
      } else {
        // 로그인 실패 처리
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  title: Text("로그인 실패"),
                  content: Text("아이디 또는 비밀번호를 확인해주세요."),
                ));
      }
    } catch (e) {
      // 예외 처리
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text("로그인 오류"),
                content: Text("서버에 문제가 발생했습니다."),
              ));
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      print("구글 로그인 클릭");
      // 구글 로그인
      final GoogleSignIn googleSignIn =
          GoogleSignIn(scopes: ['email', 'profile']);
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
      final apiAddress =
          Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login/google");
      final headers = {'Content-Type': 'application/json'};

      // Spring boot로 idToken 전달
      final response = await http.post(apiAddress,
          headers: headers, body: json.encode({'idToken': idToken}));

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

        // 즐겨찾기 목록 불러오기
        final container = ProviderContainer();
        await ServerRequest().serverRequest(({bool isFinalRequest = false}) => container.read(favoriteProvider.notifier).fetchFavoriteRestaurants(isFinalRequest: isFinalRequest), context);

        print("existNickName: ${existNickName}");

        if (existNickName) {
          // 로그인 성공 후 닉네임이 있을 경우, 메인 화면으로 이동
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          // 로그인 성공 후 닉네임이 없을 경우, 닉네임 등록 화면으로 이동
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NicknameRegistrationScreen()));
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
      // 로그인 (토큰 가져오기)
      await FlutterNaverLogin.logIn(); // 네이버 로그인 시도
      NaverAccessToken token =
          await FlutterNaverLogin.currentAccessToken; // 토큰 가져오기
      print("네이버 로그인 성공: ${token.accessToken}");

      // // .env에서 서버 URL 가져오기
      final apiAddress =
          Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login/naver");
      final headers = {'Content-Type': 'application/json'};

      // Spring boot로 token 전달
      final response = await http.post(apiAddress,
          headers: headers,
          body: json.encode({'accessToken': token.accessToken}));

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

        // 즐겨찾기 목록 불러오기
        final container = ProviderContainer();
        await ServerRequest().serverRequest(({bool isFinalRequest = false}) => container.read(favoriteProvider.notifier).fetchFavoriteRestaurants(isFinalRequest: isFinalRequest), context);

        if (existNickName) {
          // 로그인 성공 후 닉네임이 있을 경우, 메인 화면으로 이동
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          // 로그인 성공 후 닉네임이 없을 경우, 닉네임 등록 화면으로 이동
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NicknameRegistrationScreen()));
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
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Column(
            children: [
              Container(
                // 로고
                margin: const EdgeInsets.fromLTRB(0, 50, 0, 30),
                child: Image.asset(
                  'assets/images/gachi_janchi_logo.png',
                  fit: BoxFit.contain,
                  height: 150,
                ),
              ),
              Container(
                // 로그인폼 부분
                child: Column(
                  children: [
                    Form(
                      // 아이디 & 비밀번호 입력 부분
                      key: formKey,
                      child: Column(
                        children: [
                          Container(
                            // 아이디 입력 부분
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "아이디",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextFormField(
                                  controller: idController,
                                  focusNode: idFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode: AutovalidateMode.onUnfocus,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "아이디를 입력해주세요.";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "아이디를 입력해주세요.",
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  121, 55, 64, 0.612))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  122, 11, 11, 1)))),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // 비밀번호 입력 부분
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "비밀번호",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  121, 55, 64, 0.612))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  122, 11, 11, 1)))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // 로그인 버튼 부분
                      child: Column(
                        children: [
                          Container(
                            // 로그인 상태 유지 체크박스 부분
                            child: Row(
                              children: [
                                Checkbox(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    value: isAutoLogin,
                                    onChanged: (value) {
                                      setState(() {
                                        isAutoLogin = value;
                                      });
                                      saveIsAutoLogin(isAutoLogin);
                                      print("isAutoLogin: ${isAutoLogin}");
                                    }),
                                const Text(
                                  "로그인 상태 유지",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // 로그인 버튼
                            child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    print("id: ${idController.text}");
                                    print(
                                        "password: ${passwordController.text}");
                                    login();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor:
                                        const Color.fromRGBO(122, 11, 11, 1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Text(
                                  "로그인",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FindIdScreen()));
                                },
                                child: const Text(
                                  "아이디 찾기",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 41, 41, 41)),
                                ),
                              ),
                              const Text("|"),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FindPasswordScreen()));
                                },
                                child: const Text(
                                  "비밀번호 찾기",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 41, 41, 41)),
                                ),
                              ),
                              const Text("|"),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen()));
                                },
                                child: const Text(
                                  "회원가입",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 41, 41, 41)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      // 소셜로그인 부분
                      height: 200,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // 구글 로그인 버튼
                            child: ElevatedButton(
                                onPressed: () {
                                  handleGoogleSignIn();
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor:
                                        const Color.fromARGB(255, 14, 31, 184),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Text(
                                  "구글",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          SizedBox(height: 20),
                          Container(
                            // 네이버 로그인 버튼
                            child: ElevatedButton(
                                onPressed: () {
                                  handleNaverSignIn();
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 182, 67),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Text(
                                  "네이버",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
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
