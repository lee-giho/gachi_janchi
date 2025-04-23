import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/secure_storage.dart';
import 'mypage_screen.dart';
import '../widgets/ProfileWidget.dart';
import 'collected_ingredients_screen.dart';
import 'visit_history_screen.dart';
import 'reviews_screen.dart';
import 'discount_coupons_screen.dart';
import 'notices_screen.dart';
import 'settings_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyPageMainScreen extends StatefulWidget {
  const MyPageMainScreen({super.key});

  @override
  State<MyPageMainScreen> createState() => _MyPageMainScreenState();
}

class _MyPageMainScreenState extends State<MyPageMainScreen> {
  String nickname = "로딩 중...";
  String title = "칭호 선택";
  int level = 1;
  double progress = 0.0;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserInfo(isFinalRequest: isFinalRequest), context);
    // _fetchUserInfo();
  }

  Future<bool> _resetToDefaultImage({bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      return false;
    }

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      final response = await dio
          .delete("${dotenv.get("API_ADDRESS")}/api/user/profile-image");

      if (response.statusCode == 200) {
        setState(() {
          profileImage = null;
        });
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("기본 이미지로 변경되었습니다.")),
        );
        return true;
      } else {
        print("기본 이미지로 변경 실패");
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      if (isFinalRequest) {
        print("기본 이미지 설정 실패: $e");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("기본 이미지 설정 실패: $e")));
      }
      return false;
    }
  }

  Future<bool> _fetchUserInfo({bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("로그인이 필요합니다.")));
      return false;
    }

    try {
      var dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";
      final response =
          await dio.get("${dotenv.get("API_ADDRESS")}/api/user/info");

      if (response.statusCode == 200) {
        var data = response.data;
        int exp = data["exp"] ?? 0;
        int calculatedLevel = (exp ~/ 100) + 1;
        double calculatedProgress = (exp % 100) / 100.0;

        setState(() {
          nickname = data["nickname"] ?? "정보 없음";
          title = data["title"] ?? "칭호 선택";
          level = calculatedLevel;
          progress = calculatedProgress;
          profileImage = data["profileImage"] != null
              ? data["profileImage"]
              : null;
        });

        print("사용자 정보 가져오기 성공");
        return true;
      } else {
        print("사용자 정보 가져오기 실패");
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      if (isFinalRequest) {
        print("오류 발생: $e");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
      }
      return false;
    }
  }

  Future<bool> _uploadImage(String path, {bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) {
      return false;
    }

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
        await ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserInfo(isFinalRequest: isFinalRequest), context); // 변경 직후 갱신 추가
        // await _fetchUserInfo(); // ✅ 변경 직후 갱신 추가
        if (!mounted) return false;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("프로필 이미지가 변경되었습니다.")));

        print("프로필 이미지 변경 성공");
        return true;
      } else {
        print("프로필 이미지 변경 실패");
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      if (isFinalRequest) {
        print("이미지 업로드 실패: $e");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("이미지 업로드 실패: $e"))); 
      }
      return false;
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
                    foregroundColor: Colors.white,
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
                      ServerRequest().serverRequest(({bool isFinalRequest = false}) => _uploadImage(pickedFile.path, isFinalRequest: isFinalRequest), context);
                      // await _uploadImage(pickedFile.path);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person, color: Colors.purple),
                  label: const Text("기본 이미지 선택",
                      style: TextStyle(color: Colors.purple)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
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
                    await ServerRequest().serverRequest(({bool isFinalRequest = false}) => _resetToDefaultImage(isFinalRequest: isFinalRequest), context);
                    // await _resetToDefaultImage();
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
        child: Dialog(
          child: Image(
            image: NetworkImage(profileImage!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "마이페이지",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MypageScreen()),
                ).then((_) {
                  ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserInfo(isFinalRequest: isFinalRequest), context);
                  // _fetchUserInfo();
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
                    GestureDetector(
                      onTap: _showProfileOptions,
                      onLongPress: _showImagePreview,
                      child: ProfileWidget(
                        key: UniqueKey(),
                        imagePath: profileImage,
                      ),
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
                Icons.shopping_basket, "모은재료", CollectedIngredientsScreen()),
            // _buildMenuItem(Icons.receipt, "방문내역", VisitHistoryScreen()),
            _buildMenuItem(
              Icons.comment, 
              "리뷰", 
              ReviewsScreen(
                fetchUserInfo: () {
                  ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchUserInfo(isFinalRequest: isFinalRequest), context);
                }
                // _fetchUserInfo,
              )
            ),
            _buildMenuItem(Icons.campaign, "공지사항", NoticesScreen()),
            _buildMenuItem(Icons.settings, "설정", SettingsScreen()),
          ],
        ),
      ),
    );
  }

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
