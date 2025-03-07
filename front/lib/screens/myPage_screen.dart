import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';
import 'package:gachi_janchi/screens/login_screen.dart';
import 'edit_nickname_screen.dart';
import 'edit_title_screen.dart'; // ✅ 기존 파일 사용
import 'edit_name_screen.dart';
import 'edit_email_screen.dart';
import 'edit_password_screen.dart';
import 'VerifyPasswordScreen.dart';
import 'ProfileWidget.dart'; // ✅ 프로필 위젯 추가

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  String nickname = "로딩 중...";
  String selectedTitle = "칭호 없음"; // ✅ 대표 칭호 저장
  String name = "로딩 중...";
  String email = "로딩 중...";
  String loginType = ""; // ✅ 로그인 유형 (local 또는 social)
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  /// ✅ 서버에서 사용자 정보를 가져오는 함수
  Future<void> _fetchUserInfo() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      print("🔹 [API 요청] GET /api/user/info");
      final response = await dio.get("http://localhost:8080/api/user/info");

      if (response.statusCode == 200) {
        var data = response.data;
        setState(() {
          nickname = data["nickname"] ?? "정보 없음";
          selectedTitle = data["title"] ?? "칭호 없음"; // ✅ 대표 칭호 업데이트
          name = data["name"] ?? "정보 없음";
          loginType = data["type"] ?? "local";
          email = loginType == "social"
              ? _getUserIdFromToken(accessToken)
              : data["email"] ?? "정보 없음"; // ✅ 소셜 로그인은 userId 표시
        });
      }
    } catch (e) {
      print("❌ [API 오류] $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  /// ✅ 대표 칭호 업데이트
  void _updateTitle(String title) {
    setState(() {
      selectedTitle = title;
    });
  }

  /// ✅ JWT 토큰에서 `userId` 추출하는 함수
  String _getUserIdFromToken(String token) {
    try {
      List<String> tokenParts = token.split('.');
      if (tokenParts.length != 3) {
        throw Exception("Invalid token format");
      }

      String payload = tokenParts[1];
      String decoded =
          utf8.decode(base64Url.decode(base64Url.normalize(payload)));

      Map<String, dynamic> payloadMap = json.decode(decoded);
      return payloadMap["sub"] ?? "알 수 없음";
    } catch (e) {
      print("❌ [토큰 파싱 오류] $e");
      return "알 수 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 정보 변경")),
      body: Column(
        children: [
          const SizedBox(height: 40),

          const ProfileWidget(), // ✅ 프로필 위젯 추가

          const SizedBox(height: 20),
          _buildInfoBox(),
          const SizedBox(height: 20),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// ✅ 사용자 정보 리스트 UI
  Widget _buildInfoBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        children: [
          _buildListTile("닉네임", nickname,
              onTap: () => _navigateToEditScreen(
                  EditnicknameScreen(currentValue: nickname))),

          // ✅ 대표 칭호 변경 가능
          _buildListTile("대표 칭호", selectedTitle, onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EditTitleScreen(currentTitle: selectedTitle)),
            );
            if (result != null) {
              _updateTitle(result);
            }
          }),

          _buildListTile("이름", name,
              onTap: () =>
                  _navigateToEditScreen(EditnameScreen(currentValue: name))),

          // ✅ 이메일 수정 불가능 (클릭 이벤트 제거)
          _buildListTile("이메일", email),

          if (loginType == "local")
            _buildListTile("비밀번호 변경", "",
                onTap: () =>
                    _navigateToEditScreen(const VerifyPasswordScreen())),
        ],
      ),
    );
  }

  Widget _buildListTile(String label, String value, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          if (onTap != null) const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: _logout, child: const Text("로그아웃")),
        const SizedBox(width: 20),
        TextButton(
          onPressed: _deleteAccount,
          child: const Text("회원탈퇴", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> _navigateToEditScreen(Widget editScreen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => editScreen),
    );

    if (result != null) {
      setState(() {
        _fetchUserInfo();
      });
    }
  }

  Future<void> _logout() async {
    await SecureStorage.deleteTokens();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> _deleteAccount() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("회원 탈퇴"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("정말로 회원 탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다."),
              const SizedBox(height: 10),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  hintText: "탈퇴 사유를 입력해주세요. (선택 사항)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("탈퇴"),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) return;

    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      await dio.delete("http://localhost:8080/api/user",
          data: {"reason": _reasonController.text});

      await SecureStorage.deleteTokens();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      print("❌ [API 오류] $e");
    }
  }
}
