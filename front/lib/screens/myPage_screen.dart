import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';

import 'VerifyPasswordScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/secure_storage.dart';
import 'login_screen.dart';
import 'edit_nickname_screen.dart';
import 'edit_title_screen.dart';
import 'edit_name_screen.dart';
import '../widgets/ProfileWidget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  String nickname = "로딩 중...";
  String selectedTitle = "칭호 없음";
  String name = "로딩 중...";
  String email = "로딩 중...";
  String loginType = "";
  String? profileImage;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

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

      final response =
          await dio.get("${dotenv.get("API_ADDRESS")}/api/user/info");

      if (response.statusCode == 200) {
        var data = response.data;
        setState(() {
          nickname = data["nickname"] ?? "정보 없음";
          selectedTitle = data["title"] ?? "칭호 없음";
          name = data["name"] ?? "정보 없음";
          loginType = data["type"] ?? "local";
          email = loginType == "social"
              ? _getUserIdFromToken(accessToken)
              : data["email"] ?? "정보 없음";

          profileImage = data["profileImage"] != null
              ? data["profileImage"]
              : null;
        });
      }
    } catch (e) {
      print("❌ [API 오류] $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  String _getUserIdFromToken(String token) {
    try {
      List<String> tokenParts = token.split('.');
      if (tokenParts.length != 3) throw Exception("Invalid token format");

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
          GestureDetector(
            onTap: _showProfileOptions,
            onLongPress: _showImagePreview,
            child: ProfileWidget(imagePath: profileImage),
          ),
          const SizedBox(height: 20),
          _buildInfoBox(),
          const SizedBox(height: 20),
          _buildBottomButtons(),
        ],
      ),
    );
  }

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
          _buildListTile("대표 칭호", selectedTitle, onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditTitleScreen()),
            );
            _fetchUserInfo();
          }),
          _buildListTile("이름", name,
              onTap: () =>
                  _navigateToEditScreen(EditnameScreen(currentValue: name))),
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
    // 즐겨찾기 목록 초기화
    ref.read(favoriteProvider.notifier).resetFavoriteRestaurants();

    // SecureStorage에서 토큰 삭제
    await SecureStorage.deleteTokens();

    // 자동 로그인 상태 해제
    await SecureStorage.saveIsAutoLogin(false);

    // 로그인 타입 초기화
    await SecureStorage.saveLoginType("");

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

      await dio.delete("${dotenv.get("API_ADDRESS")}/api/user",
          data: {"reason": _reasonController.text});

      await SecureStorage.deleteTokens();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      print("❌ [API 오류] $e");
    }
  }

  void _showProfileOptions() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          insetPadding: const EdgeInsets.all(30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("프로필 선택", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image, color: Colors.purple),
                  label: const Text("갤러리에서 선택",
                      style: TextStyle(color: Colors.purple)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.black12,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      await _uploadImage(pickedFile.path);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person, color: Colors.purple),
                  label: const Text("기본 이미지 선택",
                      style: TextStyle(color: Colors.purple)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.black12,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _resetToDefaultImage();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePreview() {
    if (profileImage == null) return;
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(child: Image(image: NetworkImage(profileImage!))),
      ),
    );
  }

  Future<void> _uploadImage(String path) async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      FormData formData = FormData.fromMap({
        "image":
            await MultipartFile.fromFile(path, filename: path.split("/").last),
      });

      final response = await dio.post(
        "${dotenv.get("API_ADDRESS")}/api/user/profile-image",
        data: formData,
      );

      if (response.statusCode == 200) {
        final returnedPath = response.data.toString();
        setState(() {
          profileImage = returnedPath.startsWith("http")
              ? returnedPath
              : "${dotenv.get("API_ADDRESS")}$returnedPath";
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("프로필 이미지가 변경되었습니다.")));
      }
    } catch (e) {
      print("❌ [이미지 업로드 실패] $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("이미지 업로드 실패: $e")));
    }
  }

  Future<void> _resetToDefaultImage() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      final response = await dio
          .delete("${dotenv.get("API_ADDRESS")}/api/user/profile-image");

      if (response.statusCode == 200) {
        setState(() {
          profileImage = null;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("기본 이미지로 변경되었습니다.")));
      }
    } catch (e) {
      print("❌ [기본 이미지 설정 실패] $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("기본 이미지 설정 실패: $e")));
    }
  }
}
