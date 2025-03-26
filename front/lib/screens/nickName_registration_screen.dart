import 'package:flutter/material.dart';
import 'package:gachi_janchi/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/checkValidate.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';

class NicknameRegistrationScreen extends StatefulWidget {
  const NicknameRegistrationScreen({super.key});

  @override
  State<NicknameRegistrationScreen> createState() =>
      _NicknameRegistrationScreenState();
}

class _NicknameRegistrationScreenState
    extends State<NicknameRegistrationScreen> {
  // 닉네임 입력 값 저장
  var nickNameController = TextEditingController();

  // 닉네임 FocusNode
  FocusNode nickNameFocus = FocusNode();

  // 닉네임 중복확인 여부
  bool nickNameValid = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    nickNameController.dispose();
    nickNameFocus.dispose();
  }

  // 닉네임 중복확인 요청 함수
  Future<void> checkNickNameDuplication() async {
    print("닉네임 중복확인");

    String nickName = nickNameController.text;
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse(
        "${dotenv.get("API_ADDRESS")}/api/user/duplication/nick-name?nickName=$nickName");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(
        apiAddress,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print("닉네임 중복 확인 완료");

        final data = json.decode(response.body);
        bool isDuplication = data['duplication'];

        if (isDuplication) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("중복된 닉네임입니다.")));

          setState(() {
            nickNameValid = false;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("사용 가능한 닉네임입니다.")));

          setState(() {
            nickNameValid = true;
          });
        }
      } else {
        print("닉네임 중복 확인 실패");

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("닉네임 중복 확인 실패")));
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    }
  }

  // 닉네임 저장 요청 함수
  Future<void> saveNickName() async {
    print("닉네임 저장");

    String nickName = nickNameController.text;
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress =
        Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/nick-name");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.patch(apiAddress,
          headers: headers, body: json.encode({'nickName': nickName}));

      if (response.statusCode == 200) {
        print("닉네임 저장 성공");
        // 닉네임 저장 성공 후 메인 화면으로 이동
        Navigator.pushReplacement(
            context,
            // MaterialPageRoute(builder: (context) => const TestScreen())
            MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        print("닉네임 저장 실패");

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("닉네임 저장에 실패했습니다. 입력 정보를 다시 확인해주세요.")));
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
            child: Form(
                key: formKey,
                child: Container(
                  // 전체 화면
                  padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                  child: Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "잔치를 시작해볼까요?",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // 닉네임 입력 부분
                              child: Column(
                                children: [
                                  const Text(
                                    "잔치를 여실 용사님의 이름을 알려주세요.",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: nickNameController,
                                          focusNode: nickNameFocus,
                                          keyboardType: TextInputType.text,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            return CheckValidate()
                                                .validateNickName(
                                                    value, nickNameValid);
                                          },
                                          onChanged: (value) {
                                            // 닉네임이 변경될 때마다 중복 확인 결과 초기화
                                            if (nickNameValid) {
                                              setState(() {
                                                nickNameValid = false;
                                              });
                                            }
                                          },
                                          decoration: const InputDecoration(
                                              hintText: "닉네임을 입력해주세요."),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                          onPressed: () {
                                            checkNickNameDuplication();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(100, 50),
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      122, 11, 11, 1),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                          child: const Text(
                                            "중복확인",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                      Container(
                        child: ElevatedButton(
                            onPressed:
                                (formKey.currentState?.validate() ?? false) &&
                                        nickNameValid
                                    ? () {
                                        print("시작하기 버튼 클릭");

                                        saveNickName();
                                      }
                                    : null,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor:
                                    const Color.fromRGBO(122, 11, 11, 1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            child: const Text(
                              "시작하기",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      )
                    ],
                  ),
                ))));
  }
}
