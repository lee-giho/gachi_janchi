import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';
import 'edit_nickname_screen.dart';
import 'edit_title_screen.dart';
import 'edit_name_screen.dart';
import 'edit_email_screen.dart';
import 'edit_password_screen.dart';
import 'package:gachi_janchi/screens/login_screen.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  String nickname = "로딩 중...";
  String title = "로딩 중...";
  String name = "로딩 중...";
  String email = "로딩 중...";
  final TextEditingController _reasonController =
      TextEditingController(); // ✅ 탈퇴 사유 입력 컨트롤러

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

      final response = await dio.get("http://localhost:8080/api/user/info");

      if (response.statusCode == 200) {
        var data = response.data;
        setState(() {
          nickname = data["nickname"] ?? "정보 없음";
          title = data["title"] ?? "정보 없음";
          name = data["name"] ?? "정보 없음";
          email = data["email"] ?? "정보 없음";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  /// ✅ 수정 페이지로 이동
  Future<void> _navigateToEditScreen(Widget editScreen, String field) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => editScreen),
    );

    if (result != null) {
      setState(() {
        if (field == "닉네임") nickname = result;
        if (field == "칭호") title = result;
        if (field == "이름") name = result;
        if (field == "이메일") email = result;
      });
    }
  }

  /// ✅ 로그아웃 기능
  Future<void> _logout() async {
    await SecureStorage.deleteTokens();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  /// ✅ 회원 탈퇴 기능
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

      final response = await dio.delete(
        "http://localhost:8080/api/user",
        data: {"reason": _reasonController.text}, // ✅ 탈퇴 사유 포함
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("회원 탈퇴가 완료되었습니다.")));

        // ✅ 회원 탈퇴 후 모든 토큰 삭제 및 로그인 화면으로 이동
        await SecureStorage.deleteTokens();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회원 탈퇴 실패: ${response.data}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 정보 변경")),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.yellow,
            child: Icon(Icons.emoji_emotions, size: 50, color: Colors.black),
          ),
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
                  EditnicknameScreen(currentValue: nickname), "닉네임")),
          _buildListTile("칭호", title,
              onTap: () => _navigateToEditScreen(EdittitleScreen(), "칭호")),
          _buildListTile("이름", name,
              onTap: () => _navigateToEditScreen(
                  EditnameScreen(currentValue: name), "이름")),
          _buildListTile("이메일", email,
              onTap: () => _navigateToEditScreen(
                  EditemailScreen(currentValue: email), "이메일")),
          _buildListTile("비밀번호 변경", "",
              onTap: () =>
                  _navigateToEditScreen(const EditpasswordScreen(), "비밀번호")),
        ],
      ),
    );
  }

  /// ✅ 리스트 항목 생성 함수
  Widget _buildListTile(String label, String value, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  /// ✅ 로그아웃 & 회원탈퇴 버튼
  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: _logout, child: const Text("로그아웃")),
        const SizedBox(width: 20),
        TextButton(
          onPressed: _deleteAccount, // ✅ 회원 탈퇴 버튼
          child: const Text("회원탈퇴", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
