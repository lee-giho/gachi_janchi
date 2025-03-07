import 'package:flutter/material.dart';

class EditTitleScreen extends StatefulWidget {
  final String? currentTitle; // ✅ 선택된 칭호가 없을 수도 있음

  const EditTitleScreen({super.key, this.currentTitle});

  @override
  State<EditTitleScreen> createState() => _EditTitleScreenState();
}

class _EditTitleScreenState extends State<EditTitleScreen> {
  late String selectedTitle;
  bool isExpanded = false; // ✅ 칭호 목록 펼치기/접기 상태

  // ✅ 예제 칭호 리스트
  final List<String> availableTitles = [
    "칭호 1",
    "칭호 2",
    "칭호 3",
    "칭호 4",
    "칭호 5",
    "칭호 6",
    "칭호 7",
    "칭호 8"
  ];

  final List<Color> titleColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.pink,
    Colors.lightBlue,
    Colors.purple,
    Colors.green,
    Colors.brown
  ];

  late Color selectedColor; // ✅ 선택된 칭호의 배경색

  @override
  void initState() {
    super.initState();
    selectedTitle = widget.currentTitle ?? "칭호 선택"; // ✅ 기본값 설정
    int initialIndex = availableTitles.indexOf(widget.currentTitle ?? "");
    selectedColor =
        initialIndex != -1 ? titleColors[initialIndex] : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("칭호 변경")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("용사님의 칭호를 골라주세요.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            // ✅ 현재 선택된 칭호 (펼치기/접기 버튼)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedTitle,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ✅ 칭호 목록 (펼쳐진 경우에만 보이도록)
            if (isExpanded)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(availableTitles.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTitle = availableTitles[index];
                          selectedColor = titleColors[index]; // ✅ 선택한 칭호 색으로 변경
                          isExpanded = false; // ✅ 선택 후 목록 자동 닫기
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: titleColors[index],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          availableTitles[index],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            const SizedBox(height: 20),

            // ✅ 저장 버튼 (색상 변경 없음)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedTitle);
                },
                child: const Text("저장"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
