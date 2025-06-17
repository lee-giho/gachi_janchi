import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final Dio _dio = Dio();

  Map<String, dynamic> myInfo = {
    "nickname": "",
    "ranking": 0,
    "exp": 0,
    "level": 1,
    "profileImage": null,
    "title": "",
  };

  int currentPage = 0;
  static const int pageSize = 10;
  int totalPages = 0;
  List<Map<String, dynamic>> rankings = [];

  // List<Map<String, dynamic>> get currentPageData {
  //   int start = currentPage * pageSize;
  //   int end = (start + pageSize).clamp(0, rankings.length);
  //   return rankings.sublist(start, end);
  // }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchMyInfoAndRanking(isFinalRequest: isFinalRequest), context);
    await ServerRequest().serverRequest(({bool isFinalRequest = false}) => _fetchRanking(isFinalRequest: isFinalRequest), context);
    _updateMyRanking();
  }

  Future<bool> _fetchRanking({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();

    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/user/ranking?page=$currentPage&size=$pageSize",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200) {
        final responseData = Map<String, dynamic>.from(res.data);
        final content = List<Map<String, dynamic>>.from(responseData["content"]);

        setState(() {
          rankings = content;
          totalPages = responseData["totalPages"];
        });
        
        print("랭킹 불러오기 성공");
        return true;
      } else {
        print("랭킹 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  Future<bool> _fetchMyInfoAndRanking({bool isFinalRequest = false}) async {
    String? token = await SecureStorage.getAccessToken();

    try {
      final res = await _dio.get(
        "${dotenv.get("API_ADDRESS")}/api/user/info",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (res.statusCode == 200) {
        final data = Map<String, dynamic>.from(res.data);
        String nickname = data['nickname'];
        int exp = data['exp'];
        String? profileImage = data['profileImage'];

        print("ranking userInfo: $data");

        setState(() {
          myInfo['nickname'] = nickname;
          myInfo['exp'] = exp;
          myInfo['level'] = (exp ~/ 100) + 1;
          myInfo['title'] = data['title'] ?? '';
          if (profileImage != null && profileImage.isNotEmpty) {
            myInfo['profileImage'] = profileImage;
          }
        });

        print("사용자 정보 불러오기 성공");
        return true;
      } else {
        print("사용자 정보 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
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
                user["profileImage"] != null
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage("${dotenv.env["API_ADDRESS"]}/images/profile/${user["profileImage"]}")
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(25), // 반지름도 같게
                        color: Colors.white
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
    print("user qweqweqwe: $user");
    return ListTile(
      leading: Text("${index + 1}",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          )
        ),
      title: Row(
        children: [
          user["profileImage"] != null
            ? CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage("${dotenv.env["API_ADDRESS"]}/images/profile/${user["profileImage"]}")
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['nickname'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(width: 10),
                    if (user["title"] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user["title"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
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

  void _onPageChange(int newPage) async {
    if (newPage == currentPage) return;
    setState(() {
      currentPage = newPage;
    });
    await _fetchRanking();
  }

  List<int> _getDisplayedPageNumbers(int totalPages, int currentPage, {int maxButtons = 5}) {
    if (totalPages <= maxButtons) {
      // 전체 페이지 수가 버튼 수보다 적다면 0부터 전체 페이지 수까지 모두 보여주기
      return List.generate(totalPages, (index) => index);
    }

    int start = (currentPage - (maxButtons ~/ 2)).clamp(0, totalPages - maxButtons);
    int end = start + maxButtons;

    return List.generate(end - start, (index) => start + index);
  }

  Widget _buildPageButtons() {
    final pageNumbers = _getDisplayedPageNumbers(totalPages, currentPage);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPage > 0)
          IconButton(
            icon: Icon(
              Icons.chevron_left
            ),
            onPressed: () {
              _onPageChange(currentPage - 1);
            },
          ),
        ...pageNumbers.map((page) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            onPressed: () {
              _onPageChange(page);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage == page ? Colors.blue : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            ),
            child: Text(
              "${page + 1}"
            )
          ),
        )),
        if (currentPage < totalPages - 1)
          IconButton(
            icon: const Icon(
              Icons.chevron_right
            ),
            onPressed: () {
              _onPageChange(currentPage + 1);
            },
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final top3 = currentPage == 0
      ? rankings.take(3).toList() 
      : [];
    final others = currentPage == 0
      ? rankings.skip(3).toList()
      : rankings;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              myInfo["profileImage"] != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage("${dotenv.env["API_ADDRESS"]}/images/profile/${myInfo["profileImage"]}")
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
                    "${myInfo["nickname"]}",
                    style: const TextStyle(
                      fontSize: 20
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (myInfo["title"].isNotEmpty)
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
              Text(
                "🏆 ${myInfo["ranking"]}위",
                style: const TextStyle(
                  fontSize: 20
                ),
              ),
            ],
                    ),
          ),
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
                        top3[1], 2, Colors.grey.shade400, 100
                      )
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: _buildPodiumUser(
                      top3[0], 1, Colors.amber.shade600, 130
                    )
                  ),
                  if (top3.length >= 3) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildPodiumUser(
                        top3[2], 3, Colors.brown.shade300, 90
                      )
                    ),
                  ],
                ],
              ),
            ),
          if (top3.isNotEmpty) const Divider(height: 40, thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: others.length,
              itemBuilder: (context, index) {
                int baseRank = (currentPage == 0)
                  ? 3
                  : (currentPage * pageSize);
                int rank = baseRank + index + 1;
                return _buildRankingTile(others[index], rank - 1);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPageButtons(),
          ),
        ],
      ),
    );
  }
}
