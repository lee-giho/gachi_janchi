import 'package:flutter/material.dart';
import 'package:gachi_janchi/screens/test_screen.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 정보 변경"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. 프로필 영역 (정사각형 & 중앙 배치)
            Container(
              width: double.infinity,
              height: 200, // 프로필 영역 높이 설정
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 111, 84, 84),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 프로필 이미지 (정사각형 & 원형 & 중앙 배치)
                    Container(
                      width: 100, // 가로
                      height: 100, // 세로 (가로와 동일하게)
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle, // 원형
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 10), // 텍스트와의 간격
                    const Text(
                      "프로필 이미지",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // 더 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // 그림자 방향
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Table 내용물까지 둥글게
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1), // 왼쪽: 비율 1
                    1: FlexColumnWidth(2), // 오른쪽: 비율 2
                  },
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey[300]!), // 내부 줄만 회색
                  ),
                  children: [
                    _buildTableRow("닉네임", "사용자 닉네임"),
                    _buildTableRow("칭호", "사용자 칭호"),
                    _buildTableRow("이름", "사용자 이름"),
                    _buildTableRow("이메일", "user@example.com"),
                    _buildTableRow("비밀번호 변경", "********"),
                  ],
                ),
              ),
            ),

            // 4. 테스트 페이지 이동 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TestScreen()));
              },
              child: const Text(
                "테스트 페이지",
                style: TextStyle(color: Color.fromARGB(255, 41, 41, 41)),
              ),
            ),

            // 5. 로그아웃 & 회원탈퇴 버튼
            // 5. 로그아웃 & 회원탈퇴 버튼 (한 줄로 배치)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // 로그아웃 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 로그아웃 로직 추가
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("로그아웃 되었습니다.")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(
                        "로그아웃",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // 버튼 간 간격
                  // 회원 탈퇴 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 회원탈퇴 로직 추가
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("회원탈퇴가 완료되었습니다.")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(
                        "회원 탈퇴",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Table Row 생성 함수
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft, // 왼쪽 정렬
          color: Colors.grey[300],

          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerRight, // 오른쪽 정렬
          child: Text(value),
        ),
      ],
    );
  }
}
