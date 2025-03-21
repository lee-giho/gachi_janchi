import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final Dio _dio = Dio();
  String nickname = "로딩 중...";
  int ranking = 0;
  String title = "초보 맛객";
  Map<String, int> userIngredients = {};
  List<String> completedCollections = [];

  // ✅ 20개의 컬렉션 데이터
  final List<Map<String, dynamic>> collections = [
    {
      "name": "김치찌개",
      "imagePath": "assets/images/kimchi_stew.png",
      "ingredients": {"마늘": 1, "고기": 1, "버섯": 1, "토마토": 1}
    },
    {
      "name": "된장찌개",
      "imagePath": "assets/images/doenjang_stew.png",
      "ingredients": {"마늘": 1, "버섯": 1, "가지": 1, "계란": 1}
    },
    {
      "name": "불고기",
      "imagePath": "assets/images/bulgogi.png",
      "ingredients": {"고기": 2, "마늘": 1, "당근": 1}
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserIngredients();
    _fetchUserCollections();
  }

  /// ✅ 유저 정보 가져오기
  Future<void> _fetchUserData() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    try {
      Response response = await _dio.get(
        "http://localhost:8080/api/user/info",
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          nickname = response.data["nickname"];
          ranking = response.data["ranking"] ?? 999;
          title = response.data["title"] ?? "초보 맛객";
        });
      }
    } catch (e) {
      print("❌ [API 오류] 유저 정보 가져오기 실패: $e");
    }
  }

  /// ✅ 유저 보유 재료 가져오기
  Future<void> _fetchUserIngredients() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    try {
      Response response = await _dio.get(
        "http://localhost:8080/api/ingredients/user",
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userIngredients = {
            for (var item in response.data)
              item["ingredientName"]: item["quantity"]
          };
        });
      }
    } catch (e) {
      print("❌ [API 오류] 유저 재료 목록 가져오기 실패: $e");
    }
  }

  /// ✅ 유저가 완성한 컬렉션 가져오기
  Future<void> _fetchUserCollections() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    try {
      Response response = await _dio.get(
        "http://localhost:8080/api/collections/user",
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          completedCollections = List<String>.from(
              response.data.map((item) => item["collectionName"].toString()));
        });
      }
    } catch (e) {
      print("❌ [API 오류] 유저 컬렉션 가져오기 실패: $e");
    }
  }

  /// ✅ 컬렉션 완성하기
  Future<void> _completeCollection(String collectionName) async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    try {
      Response response = await _dio.post(
        "http://localhost:8080/api/collections/complete",
        data: {"collectionName": collectionName},
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          completedCollections.add(collectionName);
        });

        await Future.delayed(const Duration(milliseconds: 500));
        _fetchUserIngredients();
      }
    } catch (e) {
      print("❌ [API 오류] 컬렉션 완성 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🍲 음식 컬렉션")),
      body: Column(
        children: [
          // ✅ 유저 정보 UI
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("닉네임: $nickname",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("순위: ${ranking}위",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(title,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: collections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final collection = collections[index];
                bool isCompleted =
                    completedCollections.contains(collection["name"]);

                bool canComplete = collection["ingredients"].entries.every(
                    (entry) =>
                        userIngredients.containsKey(entry.key) &&
                        userIngredients[entry.key]! >= entry.value);

                return Card(
                  color: isCompleted ? Colors.grey[300] : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Image.asset(collection["imagePath"],
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover),
                      Text(collection["name"]),
                      ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : (canComplete
                                ? () => _completeCollection(collection["name"])
                                : null),
                        child: Text(isCompleted
                            ? "완성됨"
                            : (canComplete ? "완성하기" : "재료 부족")),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
