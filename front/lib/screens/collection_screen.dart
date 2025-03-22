import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;
import '../utils/secure_storage.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with TickerProviderStateMixin {
  final Dio _dio = Dio();
  String nickname = "로딩 중...";
  int ranking = 0;
  String title = "초보 맛객";

  Map<String, int> userIngredients = {};
  List<String> completedCollections = [];
  List<String> unlockedCollections = [];
  List<Map<String, dynamic>> collections = [];

  late final AnimationController _lockAnimation;
  late final Animation<double> _lockOffset;

  @override
  void initState() {
    super.initState();
    _lockAnimation = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _lockOffset = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _lockAnimation, curve: Curves.easeInOut),
    );

    _fetchUserData();
    _fetchUserIngredients();
    _fetchCollections();
    _fetchUserCollections();
  }

  @override
  void dispose() {
    _lockAnimation.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) return;
    try {
      final res = await _dio.get(
        "http://localhost:8080/api/user/info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          nickname = res.data["nickname"];
          ranking = res.data["ranking"] ?? 999;
          title = res.data["title"] ?? "초보 맛객";
        });
      }
    } catch (e) {
      print("❌ 유저 정보 실패: $e");
    }
  }

  Future<void> _fetchUserIngredients() async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) return;
    try {
      final res = await _dio.get(
        "http://localhost:8080/api/ingredients/user",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          userIngredients = {
            for (var i in res.data) i["ingredientName"]: i["quantity"]
          };
        });
      }
    } catch (e) {
      print("❌ 재료 가져오기 실패: $e");
    }
  }

  Future<void> _fetchCollections() async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) return;
    try {
      final res = await _dio.get(
        "http://localhost:8080/api/collections",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        final raw = List<Map<String, dynamic>>.from(res.data);

        // ✅ 재료 이름순 정렬
        for (var collection in raw) {
          List ingredients = collection["ingredients"];
          ingredients.sort(
              (a, b) => (a["name"] as String).compareTo(b["name"] as String));
        }

        setState(() {
          collections = raw;
        });
      }
    } catch (e) {
      print("❌ 컬렉션 목록 실패: $e");
    }
  }

  Future<void> _fetchUserCollections() async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) return;
    try {
      final res = await _dio.get(
        "http://localhost:8080/api/collections/user",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          completedCollections = List<String>.from(
              res.data.map((e) => e["collectionName"].toString()));
        });
      }
    } catch (e) {
      print("❌ 유저 컬렉션 실패: $e");
    }
  }

  Future<void> _completeCollection(String name) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) return;
    try {
      final res = await _dio.post(
        "http://localhost:8080/api/collections/complete",
        data: {"collectionName": name},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          completedCollections.add(name);
        });
        await _fetchUserIngredients();
      }
    } catch (e) {
      print("❌ 컬렉션 완성 실패: $e");
    }
  }

  void _showCompleteDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("컬렉션 완성"),
        content: Text("‘$name’을(를) 완성할까요?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("취소")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeCollection(name);
              },
              child: const Text("완성하기")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🍲 음식 컬렉션")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 유저 정보
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

            // 컬렉션 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: collections.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final collection = collections[index];
                final name = collection["name"];
                final description = collection["description"];
                final List ingredients = collection["ingredients"];

                final isCompleted = completedCollections.contains(name);
                final canComplete = ingredients.every(
                    (i) => (userIngredients[i["name"]] ?? 0) >= i["quantity"]);
                final isUnlocked = canComplete && !isCompleted;
                final isLocked = !isUnlocked && !isCompleted;

                return GestureDetector(
                  onTap: () {
                    if (isUnlocked) _showCompleteDialog(name);
                  },
                  child: Stack(
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCompleted
                                ? Colors.orange
                                : Colors.grey.shade300,
                            width: isCompleted ? 2 : 1,
                          ),
                        ),
                        color: isLocked || isUnlocked
                            ? Colors.grey[440]
                            : Colors.white,
                        child: SizedBox(
                          height: 600,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.asset(
                                  collection["imagePath"],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  description,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!isCompleted)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: ingredients.map((i) {
                                    final ing = i["name"];
                                    final qty = i["quantity"];
                                    final owned = userIngredients[ing] ?? 0;
                                    final imgPath = i["imagePath"];
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          imgPath,
                                          width: 40,
                                          height: 40,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.error),
                                        ),
                                        const SizedBox(height: 4),
                                        Text("x$qty",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                        Text("$owned / $qty",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: owned >= qty
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              if (isCompleted)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text("✅ 완성됨",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (isLocked || isUnlocked)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _lockAnimation,
                            builder: (context, child) {
                              final offset = _lockOffset.value;
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(0, offset),
                                      child: Icon(
                                        isUnlocked
                                            ? Icons.lock_open
                                            : Icons.lock,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isUnlocked ? "해제 가능 🔓" : "잠김 🔒",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
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
              },
            )
          ],
        ),
      ),
    );
  }
}
