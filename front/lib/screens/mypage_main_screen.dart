import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';
import 'mypage_screen.dart';
import 'ProfileWidget.dart';
import 'collected_ingredients_screen.dart';
import 'visit_history_screen.dart';
import 'reviews_screen.dart';
import 'discount_coupons_screen.dart';
import 'notices_screen.dart';
import 'settings_screen.dart';

class MyPageMainScreen extends StatefulWidget {
  const MyPageMainScreen({super.key});

  @override
  State<MyPageMainScreen> createState() => _MyPageMainScreenState();
}

class _MyPageMainScreenState extends State<MyPageMainScreen> {
  String nickname = "로딩 중...";
  String title = "칭호 선택"; // ✅ 기본값
  int level = 1;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  /// ✅ 서버에서 사용자 정보 가져오기
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
          title = data["title"] ?? "칭호 선택";
          level = data["level"] ?? 1;
          progress = (data["progress"] ?? 0) / 100.0;
        });
      }
    } catch (e) {
      print("❌ [API 오류] $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("마이페이지")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ✅ 프로필 카드 (닉네임, 칭호, 레벨)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MypageScreen()),
                ).then((_) {
                  _fetchUserInfo(); // ✅ 뒤로 가기 후 즉시 업데이트
                  setState(() {}); // ✅ 프로필도 즉시 반영
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    ProfileWidget(
                      key: UniqueKey(), // ✅ 새로운 프로필을 불러오도록 강제 업데이트
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nickname,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: title == "칭호 선택"
                                      ? Colors.grey
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "🍽️ $title",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("LV. $level",
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 28),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildMenuItem(
                Icons.percent, "할인쿠폰", const DiscountCouponsScreen()),
            _buildMenuItem(Icons.shopping_basket, "모은재료",
                const CollectedIngredientsScreen()),
            _buildMenuItem(Icons.receipt, "방문내역", const VisitHistoryScreen()),
            _buildMenuItem(
              Icons.comment,
              "리뷰",
              const ReviewsScreen(),
            ),
            _buildMenuItem(Icons.campaign, "공지사항", const NoticesScreen()),
            _buildMenuItem(Icons.settings, "설정", const SettingsScreen()),
          ],
        ),
      ),
    );
  }

  // 마이페이지 메뉴에 적용
  Widget _buildMenuItem(IconData icon, String label, Widget screen,
      {int? badgeCount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 18)),
            ),
            if (badgeCount != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$badgeCount",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.chevron_right, size: 28),
          ],
        ),
      ),
    );
  }
}
