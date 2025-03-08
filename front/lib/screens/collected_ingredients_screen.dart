import 'package:flutter/material.dart';

class CollectedIngredientsScreen extends StatelessWidget {
  CollectedIngredientsScreen({super.key});

  // ✅ 기본 제공 재료 리스트 (파일명 기반)
  final List<Map<String, dynamic>> ingredients = [
    {
      "name": "바나나",
      "imagePath": "assets/images/banana.png",
      "collected": false
    },
    {"name": "케이크", "imagePath": "assets/images/cake.png", "collected": false},
    {"name": "당근", "imagePath": "assets/images/carrot.png", "collected": false},
    {"name": "옥수수", "imagePath": "assets/images/corn.png", "collected": false},
    {"name": "계란", "imagePath": "assets/images/egg.png", "collected": false},
    {"name": "가지", "imagePath": "assets/images/gaji.png", "collected": false},
    {"name": "마늘", "imagePath": "assets/images/garlic.png", "collected": false},
    {"name": "고기", "imagePath": "assets/images/meat.png", "collected": false},
    {"name": "우유", "imagePath": "assets/images/milk.png", "collected": false},
    {
      "name": "버섯",
      "imagePath": "assets/images/mushroom.png",
      "collected": false
    },
    {
      "name": "파인애플",
      "imagePath": "assets/images/pineapple.png",
      "collected": false
    },
    {"name": "피자", "imagePath": "assets/images/pizza.png", "collected": false},
    {
      "name": "딸기",
      "imagePath": "assets/images/strawberry.png",
      "collected": false
    },
    {
      "name": "토마토",
      "imagePath": "assets/images/tomato.png",
      "collected": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ 보유한 재료 개수 계산
    int collectedCount = ingredients.where((item) => item["collected"]).length;

    return Scaffold(
      appBar: AppBar(title: const Text("모은 재료")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "보유 재료 ${collectedCount}개",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: ingredients.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // ✅ 한 줄에 3개씩 배치
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];

                  return Column(
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
                            colorFilter: ingredient["collected"]
                                ? const ColorFilter.mode(
                                    Colors.transparent, BlendMode.color)
                                : const ColorFilter.mode(
                                    Colors.grey, BlendMode.saturation),
                            child: Image.asset(
                              ingredient["imagePath"],
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ingredient["name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: ingredient["collected"]
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
