import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final Dio _dio = Dio();
  List<Map<String, dynamic>> rankings = [];
  Map<String, dynamic> myInfo = {
    "nickname": "",
    "ranking": 0,
    "exp": 0,
    "level": 1,
    "profileImagePath": null,
    "title": "",
  };

  int currentPage = 0;
  static const int pageSize = 10;

  List<Map<String, dynamic>> get currentPageData {
    int start = currentPage * pageSize;
    int end = (start + pageSize).clamp(0, rankings.length);
    return rankings.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchMyInfoAndRanking();
    await _fetchRanking();
    _updateMyRanking();
  }

  Future<void> _fetchRanking() async {
    String? token = await SecureStorage.getAccessToken();
    try {
      final res = await _dio.get(
        "http://localhost:8080/api/user/ranking?page=0&size=1000",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(res.data);
        setState(() {
          rankings = data.map((user) {
            if (user['profileImagePath'] != null &&
                !user['profileImagePath'].toString().startsWith("http")) {
              user['profileImagePath'] =
                  "http://localhost:8080" + user['profileImagePath'];
            }
            return user;
          }).toList();
        });
      }
    } catch (e) {
      print("랭킹 불러오기 실패: $e");
    }
  }

  Future<void> _fetchMyInfoAndRanking() async {
    String? token = await SecureStorage.getAccessToken();
    try {
      final res = await _dio.get(
        "http://localhost:8080/api/user/info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        final data = Map<String, dynamic>.from(res.data);
        String nickname = data['nickname'];
        int exp = data['exp'];
        String? profileImagePath = data['profileImagePath'];

        if (profileImagePath != null && !profileImagePath.startsWith("http")) {
          profileImagePath = "http://localhost:8080" + profileImagePath;
        }

        setState(() {
          myInfo['nickname'] = nickname;
          myInfo['exp'] = exp;
          myInfo['level'] = (exp ~/ 100) + 1;
          myInfo['profileImagePath'] = profileImagePath;
          myInfo['title'] = data['title'] ?? '';
        });
      }
    } catch (e) {
      print("내 정보 불러오기 실패: $e");
    }
  }

  void _updateMyRanking() {
    final index =
        rankings.indexWhere((u) => u['nickname'] == myInfo['nickname']);
    if (index != -1) {
      setState(() {
        myInfo['ranking'] = index + 1;
      });
    }
  }

  Widget _buildPodiumUser(
      Map<String, dynamic> user, int rank, Color color, double height) {
    int level = (user['exp'] ~/ 100) + 1;
    double avatarRadius = rank == 1 ? 26 : 22;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1)
          const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
        Text("#$rank",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rank == 1 ? 16 : 14,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 100,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(top: 26),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.white,
                  backgroundImage: user['profileImagePath'] != null
                      ? NetworkImage(user['profileImagePath'])
                      : null,
                  child: user['profileImagePath'] == null
                      ? Icon(Icons.person,
                          size: avatarRadius, color: Colors.grey.shade400)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(user['nickname'] ?? '',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text("LV.$level",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                if ((user['title'] is String &&
                        (user['title'] as String).isNotEmpty) ||
                    (user['title'] != null &&
                        user['title']['name'] != null &&
                        user['title']['name'].isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                          user['title'] is String
                              ? user['title']
                              : user['title']?['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRankingTile(Map<String, dynamic> user, int index) {
    int level = (user['exp'] ~/ 100) + 1;
    return ListTile(
      leading: Text("${index + 1}",
          style: const TextStyle(fontWeight: FontWeight.bold)),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: user['profileImagePath'] != null
                ? NetworkImage(user['profileImagePath'])
                : null,
            child: user['profileImagePath'] == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['nickname'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: (user['exp'] % 100) / 100,
                    minHeight: 6,
                    color: Colors.green,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: Text("LV.$level"),
    );
  }

  void _onPageChange(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFirstPage = currentPage == 0;
    final top3 = isFirstPage ? rankings.take(3).toList() : [];
    final others = isFirstPage
        ? rankings.skip(3).take(pageSize - 3).toList()
        : currentPageData;
    final totalPages = (rankings.length / pageSize).ceil();

    final podiumColors = [
      Colors.amber.shade600,
      Colors.grey.shade400,
      Colors.brown.shade300
    ];
    final podiumHeights = [140.0, 110.0, 90.0];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("👤 ${myInfo["nickname"]}"),
            Text("🏆 ${myInfo["ranking"]}위"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                myInfo["title"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (top3.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (top3.length >= 2) ...[
                    Flexible(
                        child: _buildPodiumUser(
                            top3[1], 2, Colors.grey.shade400, 100)),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                      child: _buildPodiumUser(
                          top3[0], 1, Colors.amber.shade600, 130)),
                  if (top3.length >= 3) ...[
                    const SizedBox(width: 8),
                    Flexible(
                        child: _buildPodiumUser(
                            top3[2], 3, Colors.brown.shade300, 90)),
                  ],
                ],
              ),
            ),
          if (top3.isNotEmpty) const Divider(height: 40, thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: others.length,
              itemBuilder: (context, index) {
                int rank = isFirstPage
                    ? index + 4
                    : currentPage * pageSize + index + 1;
                return _buildRankingTile(others[index], rank - 1);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  totalPages,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () => _onPageChange(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentPage == index
                                ? Colors.blue
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: Text("${index + 1}"),
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
