import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';

class CollectedIngredientsScreen extends StatefulWidget {
  const CollectedIngredientsScreen({super.key});

  @override
  State<CollectedIngredientsScreen> createState() =>
      _CollectedIngredientsScreenState();
}

class _CollectedIngredientsScreenState
    extends State<CollectedIngredientsScreen> {
  final Dio _dio = Dio(); // ✅ API 요청을 위한 Dio 인스턴스

  // ✅ 전체 재료 리스트 (이미지 포함)
  final List<Map<String, dynamic>> allIngredients = [
    {"name": "바나나", "imagePath": "assets/images/banana.png"},
    {"name": "케이크", "imagePath": "assets/images/cake.png"},
    {"name": "당근", "imagePath": "assets/images/carrot.png"},
    {"name": "옥수수", "imagePath": "assets/images/corn.png"},
    {"name": "계란", "imagePath": "assets/images/egg.png"},
    {"name": "가지", "imagePath": "assets/images/gaji.png"},
    {"name": "마늘", "imagePath": "assets/images/garlic.png"},
    {"name": "고기", "imagePath": "assets/images/meat.png"},
    {"name": "우유", "imagePath": "assets/images/milk.png"},
    {"name": "버섯", "imagePath": "assets/images/mushroom.png"},
    {"name": "파인애플", "imagePath": "assets/images/pineapple.png"},
    {"name": "피자", "imagePath": "assets/images/pizza.png"},
    {"name": "딸기", "imagePath": "assets/images/strawberry.png"},
    {"name": "토마토", "imagePath": "assets/images/tomato.png"},
  ];

  Map<String, int> userIngredients = {}; // ✅ 유저가 보유한 재료 (이름 -> 개수)

  @override
  void initState() {
    super.initState();
    _fetchUserIngredients(); // ✅ 유저 보유 재료 불러오기
  }

  /// ✅ 유저가 보유한 재료 불러오기 (서버 호출)
  Future<void> _fetchUserIngredients() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      print("❌ [ERROR] 로그인 필요! (토큰 없음)");
      return;
    }

    try {
      print("🔹 [API 요청] 유저 보유 재료 목록 불러오기");

      Response response = await _dio.get(
        "http://localhost:8080/api/ingredients/user",
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json"
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        setState(() {
          userIngredients = {
            for (var item in data) item["ingredientName"]: item["quantity"]
          };
        });
        print("✅ [성공] 보유한 재료 목록 업데이트");
      }
    } catch (e) {
      print("❌ [API 오류]: $e");
    }
  }

  /// ✅ 재료 추가 요청 (서버에 추가)
  Future<void> _addIngredient(String ingredientName) async {
    String? accessToken = await SecureStorage.getAccessToken();

    if (accessToken == null) {
      print("❌ [ERROR] 로그인 필요! (토큰 없음)");
      return;
    }

    try {
      print("🔹 [API 요청] 재료 추가: $ingredientName");

      Response response = await _dio.post(
        "http://localhost:8080/api/ingredients/add",
        data: {"ingredientName": ingredientName},
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json"
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          userIngredients.update(ingredientName, (value) => value + 1,
              ifAbsent: () => 1);
        });
        print("✅ [성공] '${ingredientName}' 추가됨");
      }
    } catch (e) {
      print("❌ [API 오류]: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 재료 목록")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: allIngredients.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // ✅ 한 줄에 3개씩 배치
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final ingredient = allIngredients[index];
            String name = ingredient["name"];
            bool isCollected = userIngredients.containsKey(name);
            int quantity = userIngredients[name] ?? 0;

            return GestureDetector(
              onTap: () => _addIngredient(name), // ✅ 클릭하면 재료 추가
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Center(
                          child: ColorFiltered(
                            colorFilter: isCollected
                                ? const ColorFilter.mode(
                                    Colors.transparent, BlendMode.dst)
                                : const ColorFilter.matrix([
                                    0.2126, 0.7152, 0.0722, 0, 0, // Red
                                    0.2126, 0.7152, 0.0722, 0, 0, // Green
                                    0.2126, 0.7152, 0.0722, 0, 0, // Blue
                                    0, 0, 0, 1, 0, // Alpha
                                  ]),
                            child: Image.asset(
                              ingredient["imagePath"],
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      if (isCollected)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$quantity",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCollected ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
