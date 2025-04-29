import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:gachi_janchi/utils/translation.dart';
import 'dart:math' as math;
import '../utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:developer';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen>
    with TickerProviderStateMixin {
  final Dio _dio = Dio();
  String nickname = "";
  int ranking = 0;
  String title = "";
  int exp = 0;
  String profileImage = "";

  Map<String, int> userIngredients = {};
  List<String> completedCollections = [];
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

    _initializeUserInfo();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserIngredients(isFinalRequest: isFinalRequest), context);
    // _fetchUserIngredients();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchCollections(isFinalRequest: isFinalRequest), context);
    // _fetchCollections();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserCollections(isFinalRequest: isFinalRequest), context);
    // _fetchUserCollections();
  }

  Future<void> _initializeUserInfo() async {
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserData(isFinalRequest: isFinalRequest), context);
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserRanking(isFinalRequest: isFinalRequest), context);
    // await _fetchUserData();
    // await _fetchUserRanking();
  }

  @override
  void dispose() {
    _lockAnimation.dispose();
    super.dispose();
  }

  Future<bool> _fetchUserData({bool isFinalRequest = false}) async {
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/info").toString();
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      final res = await _dio.get(
        apiAddress,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        print("data: ${res.data}");
        setState(() {
          nickname = res.data["nickname"];
          title = res.data["title"] ?? "";
          exp = res.data["exp"];
          if (res.data["profileImage"] != null && res.data["profileImage"].isNotEmpty){
            profileImage = res.data["profileImage"];
          }
        });
        print("유저 정보 불러옴");
        return true;
      } else {
        print("유저 정보 불러오기 실패");
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

  Future<bool> _fetchUserRanking({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/user/ranking?page=0&size=1000",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        final List rankings = res.data;
        final index =
            rankings.indexWhere((user) => user["nickname"] == nickname);
        if (index != -1) {
          setState(() {
            ranking = index + 1;
          });
        }
        print("유저 랭킹 불러옴");
        return true;
      } else {
        print("유저 랭킹 불러오기 실패");
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

  Future<bool> _fetchUserIngredients({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/ingredients/user",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          userIngredients = {
            for (var i in res.data) i["ingredientName"]: i["quantity"]
          };
        });
        print("사용자가 보유한 재료 가져옴");
        return true;
      } else {
        print("사용자가 보유한 재료 가져오기 실패");
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

  Future<bool> _fetchCollections({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/collections",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        final raw = List<Map<String, dynamic>>.from(res.data);

        for (var collection in raw) {
          List ingredients = collection["ingredients"];
          ingredients.sort(
              (a, b) => (a["name"] as String).compareTo(b["name"] as String));
        }

        setState(() {
          collections = raw.where((c) => c["name"] != null).toList();
        });
        print("컬렉션 목록 불러옴");
        return true;
      } else {
        print("컬렉션 목록 불러오기 실패");
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

  Future<bool> _fetchUserCollections({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/collections/user",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        setState(() {
          completedCollections = List<String>.from(
              res.data.map((e) => e["collectionName"].toString()));
        });
        print("유저 컬렉션 목록 불러옴");
        return true;
      } else {
        print("유저 컬렉션 불러오기 실패");
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

  Future<bool> _completeCollection(String name, {bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();
    if (token == null) {
      return false;
    }
    try {
      final res = await _dio.post(
        "${dotenv.get("API_ADDRESS")}/api/collections/complete",
        data: {"collectionName": name},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        setState(() {
          completedCollections.add(name);
        });
        ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserIngredients(isFinalRequest: isFinalRequest), context);
        // await _fetchUserIngredients();
        print("컬렉션 완성 성공");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("컬렉션 획득")));
        return true;
      } else {
        print("컬렉션 완성 실패");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("컬렉션 획득 실패")));
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

  void _showCompleteDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("컬렉션 완성"),
        content: Text("‘${Translation.translateCollection(name)}’을(를) 완성할까요?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    width: 0.5
                  )
                )
              ),
              child: const Text(
                "취소",
                style: TextStyle(
                  color: const Color.fromRGBO(122, 11, 11, 1),
                ),
              )
          ),
          ElevatedButton(
              onPressed: () async{
                final result = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => _completeCollection(name, isFinalRequest: isFinalRequest), context);
                if (result) {
                  Navigator.pop(context);
                }
                // _completeCollection(name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                )
              ),
              child: const Text(
                "완성하기",
                style: TextStyle(
                  color: Colors.white
                ),
              )
          ),
        ],
      ),
    );
  }

  String toAssetPath(String name) {
    return 'assets/images/collection/${name.replaceAll(' ', '').replaceAll('\n', '')}.png';
  }

  String toIngredientAssetPath(String name) {
    return 'assets/images/ingredient/${name.replaceAll(' ', '').replaceAll('\n', '')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                profileImage.isNotEmpty
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage("${dotenv.env["API_ADDRESS"]}/images/profile/${profileImage}")
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(25), // 반지름도 같게
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3.0), // 내부 padding 적용
                        child: Icon(
                          Icons.person,
                          size: 44, // 아이콘 크기는 padding 고려해서 살짝 줄이기
                          color: Colors.grey,
                        ),
                      ),
                    ),
                Row(
                  children: [
                    Text(
                      "$nickname",
                      style: const TextStyle(
                        fontSize: 20
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (title.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  "🏆 ${ranking}위",
                  style: const TextStyle(
                    fontSize: 20
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                      final name = collection["name"] ?? "default";
                      final description = collection["description"] ?? "";
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
                                height: 650,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12)),
                                          child: Image.asset(
                                            toAssetPath(name),
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(Translation.translateCollection(name),
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
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!isCompleted)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        alignment: WrapAlignment.center,
                                        children: ingredients.map((i) {
                                          final ing = i["name"];
                                          final qty = i["quantity"];
                                          final owned = userIngredients[ing] ?? 0;
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                toIngredientAssetPath(ing),
                                                width: 35,
                                                height: 35,
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
          ),
        ],
      ),
    );
  }
}
