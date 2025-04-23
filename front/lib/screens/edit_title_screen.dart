import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import '../utils/secure_storage.dart';
import 'package:gachi_janchi/utils/translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EditTitleScreen extends StatefulWidget {
  const EditTitleScreen({super.key});

  @override
  State<EditTitleScreen> createState() => _EditTitleScreenState();
}

class _EditTitleScreenState extends State<EditTitleScreen> {
  final Dio _dio = Dio();
  List<dynamic> userTitles = [];
  List<dynamic> allTitleConditions = [];
  String? selectedTitle;
  int? selectedTitleId;

  @override
  void initState() {
    super.initState();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserInfoAndTitles(isFinalRequest: isFinalRequest), context);
    // _fetchUserInfoAndTitles();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchAllTitleProgress(isFinalRequest: isFinalRequest), context);
    // _fetchAllTitleProgress();
  }

  Future<bool> _fetchUserInfoAndTitles({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }

    try {
      final userRes = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/user/info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      String? userTitleName;
      if (userRes.statusCode == 200) {
        userTitleName = userRes.data['title']?.toString().trim();
        print("\uD83D\uDC51 현재 대표 칭호: $userTitleName");
      }

      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/titles/user",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        final data = res.data;
        print("\uD83D\uDCE6 유저 칭호 목록: $data");

        final match = data.firstWhere(
          (t) => t['titleName'].toString().trim() == userTitleName,
          orElse: () => null,
        );

        setState(() {
          userTitles = data;
          selectedTitleId = match != null ? match['titleId'] : null;
          selectedTitle = match != null ? match['titleName'] : null;
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("\u274C 유저 정보 또는 칭호 목록 불러오기 실패: $e");
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  Future<bool> _fetchAllTitleProgress({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }

    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/titles/progress",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          allTitleConditions = res.data;
        });
        print("칭호 진행도 불러오기 성공");
        return true;
      } else {
        print("칭호 진행도 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("\u274C 칭호 진행도 불러오기 실패: $e");
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  Future<bool> _saveSelectedTitle(int? titleId, String titleName, {bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }

    try {
      final res = await _dio.post(
        "${dotenv.get("API_ADDRESS")}/api/titles/set",
        data: {"titleId": titleId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        print("\u2705 대표 칭호 저장 완료: $titleName ($titleId)");
        return true;
      } else {
        print("\u274C 대표 칭호 설정 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("\u274C 대표 칭호 설정 실패: $e");
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  Future<bool> _claimTitle(int titleId, {bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }

    try {
      final res = await _dio.post(
        "${dotenv.get("API_ADDRESS")}/api/titles/claim",
        data: {"titleId": titleId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        print("\uD83C\uDFC5 칭호 획득 성공: $titleId");
        ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserInfoAndTitles(isFinalRequest: isFinalRequest), context);
        // _fetchUserInfoAndTitles();
        ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchAllTitleProgress(isFinalRequest: isFinalRequest), context);
        // _fetchAllTitleProgress();
        return true;
      } else {
        print("\u274C 칭호 획득 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("\u274C 칭호 획득 실패: $e");
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  bool isOwned(String titleName) {
    return userTitles.any((t) => t['titleName'] == titleName);
  }

  String getConditionText(dynamic title) {
    final type = title['conditionType'];
    final value = title['conditionValue'];

    switch (type) {
      case "DEFAULT":
        return "기본 칭호";
      case "INGREDIENT":
        return "재료 $value개 수집 (현재: ${title['progress']})";
      case "COLLECTION":
        return "컬렉션 $value개 완성 (현재: ${title['progress']})";
      case "COLLECTION_NAME":
        return "${Translation.translateCollection(value)} 컬렉션 완성";
      case "COLLECTION_NAMES":
        final names = value.toString().split(',');
        final translated = names
            .map((e) => Translation.translateCollection(e.trim()))
            .join(", ");
        return "$translated 컬렉션 완성";
      case "ALL_COLLECTIONS":
        return "모든 컬렉션 완성";
      case "ALL_INGREDIENTS":
        return "모든 재료 수집";
      default:
        return "조건 정보 없음";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("대표 칭호 설정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("대표 칭호 선택",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: selectedTitleId,
                hint: const Text("칭호를 선택하세요"),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text("칭호 없음"),
                  ),
                  ...userTitles.map<DropdownMenuItem<int?>>((t) {
                    return DropdownMenuItem<int?>(
                      value: t['titleId'],
                      child: Text(t['titleName']),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  final selected = userTitles.firstWhere(
                    (t) => t['titleId'] == value,
                    orElse: () => {'titleName': "칭호 없음"},
                  );

                  setState(() {
                    selectedTitleId = value;
                    selectedTitle = selected['titleName'];
                  });

                  ServerRequest().serverRequest(({bool isFinalRequest = false}) => _saveSelectedTitle(value, selected['titleName'], isFinalRequest: isFinalRequest), context);
                  _saveSelectedTitle(value, selected['titleName']);
                },
              ),
              const SizedBox(height: 20),
              /*Center(
                child: ElevatedButton(
                  onPressed: () => _saveSelectedTitle(
                    selectedTitleId,
                    selectedTitle ?? "칭호 없음",
                  ),
                  child: const Text("저장"),
                ),
              ),*/
              const Text("획득하지 않은 칭호",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: allTitleConditions
                    .where((title) => !isOwned(title['titleName']))
                    .map((title) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading:
                          Icon(Icons.lock_outline, color: Colors.grey[600]),
                      title: Text(title['titleName']),
                      subtitle: Text("조건: ${getConditionText(title)}"),
                      trailing: (title['achievable'] == true)
                          ? TextButton(
                              onPressed: () {
                                ServerRequest().serverRequest(({bool isFinalRequest = false}) => _claimTitle(title["titleId"], isFinalRequest: isFinalRequest), context);
                              },
                              // _claimTitle(title['titleId']),
                              child: const Text("획득하기"),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
