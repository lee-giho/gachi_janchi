import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';
import 'test_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 서버에서 사용자 정보 가져오기
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("데이터 로드 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  /// ✅ 정보 수정 다이얼로그
  Future<void> _showEditDialog(String field, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$field 수정"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("취소")),
            TextButton(
              onPressed: () {
                _updateUserInfo(field, controller.text);
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  /// ✅ 서버에 업데이트 요청 보내기
  Future<void> _updateUserInfo(String field, String newValue) async {
    String? accessToken = await SecureStorage.getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      String apiUrl = "http://localhost:8080/api/user/update"; // 서버 엔드포인트
      Map<String, dynamic> data = {
        "field": field.toLowerCase(),
        "value": newValue,
      };

      final response = await dio.patch(apiUrl, data: data);

      if (response.statusCode == 200) {
        setState(() {
          if (field == "닉네임") nickname = newValue;
          if (field == "칭호") title = newValue;
          if (field == "이름") name = newValue;
          if (field == "이메일") email = newValue;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("정보가 성공적으로 업데이트되었습니다.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("업데이트 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 정보 변경"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 영역
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 111, 84, 84),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("프로필 이미지", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            // 사용자 정보 표시 (클릭하면 수정 가능)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey[300]!),
                  ),
                  children: [
                    _buildEditableTableRow("닉네임", nickname),
                    _buildEditableTableRow("칭호", title),
                    _buildEditableTableRow("이름", name),
                    _buildEditableTableRow("이메일", email),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ 클릭 가능한 테이블 행 생성 함수
  TableRow _buildEditableTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          color: Colors.grey[300],
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        GestureDetector(
          onTap: () => _showEditDialog(label, value), // 클릭 시 다이얼로그 열기
          child: Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerRight,
            child: Text(value, style: const TextStyle(color: Colors.blue)),
          ),
        ),
      ],
    );
  }
}
