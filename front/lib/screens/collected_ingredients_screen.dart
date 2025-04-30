import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:gachi_janchi/utils/translation.dart';
import '../utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CollectedIngredientsScreen extends StatefulWidget {
  const CollectedIngredientsScreen({super.key});

  @override
  State<CollectedIngredientsScreen> createState() =>
      _CollectedIngredientsScreenState();
}

class _CollectedIngredientsScreenState
    extends State<CollectedIngredientsScreen> {
  final Dio _dio = Dio();

  List<Map<String, dynamic>> allIngredients = []; // 서버에서 받아온 전체 재료 정보
  Map<String, int> userIngredients = {}; // 유저가 보유한 재료 (이름 -> 개수)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchAllIngredients(isFinalRequest: isFinalRequest), context);
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserIngredients(isFinalRequest: isFinalRequest), context);
  }

  /// 전체 재료 목록 불러오기 (이름순 정렬 추가됨)
  Future<bool> _fetchAllIngredients({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false; 
    }

    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/ingredients/all",
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (res.statusCode == 200) {
        List<Map<String, dynamic>> raw =
            List<Map<String, dynamic>>.from(res.data);

        // 이름순 정렬
        raw.sort(
            (a, b) => (a["name"] as String).compareTo(b["name"] as String));

        setState(() {
          allIngredients = raw;
        });
        print("전체 재료 목록 불러옴");
        return true;
      } else {
        print("전체 재료 목록 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  /// 유저 보유 재료 불러오기
  Future<bool> _fetchUserIngredients({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }

    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/ingredients/user",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );

      if (res.statusCode == 200) {
        List<dynamic> data = res.data;
        setState(() {
          userIngredients = {
            for (var item in data) item["ingredientName"]: item["quantity"]
          };
        });
        print("유저 보유 재료 불러옴");
        return true;
      } else {
        print("유저 보유 재료 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allIngredients.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("내 재료 목록")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: allIngredients.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final ingredient = allIngredients[index];
            String name = ingredient["name"];
            String imagePath = 'assets/images/ingredient/$name.png'; // 여기 수정
            int quantity = userIngredients[name] ?? 0;
            bool isCollected = quantity > 0;

            return GestureDetector(
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
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    1,
                                    0,
                                  ]),
                            child: Image.asset(
                              imagePath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      if (quantity > 0)
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
                    Translation.translateIngredient(name),
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
