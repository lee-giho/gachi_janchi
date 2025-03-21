import 'package:flutter/material.dart';
import 'ranking_screen.dart';
import 'collection_screen.dart';

class RankingCollectionScreen extends StatelessWidget {
  const RankingCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // ✅ 두 개의 탭 (랭킹 & 컬렉션)
      child: Scaffold(
        appBar: AppBar(
          title: const Text("랭킹 & 컬렉션"),
          bottom: const TabBar(
            labelColor: Colors.black, // 선택된 탭 색상
            unselectedLabelColor: Colors.grey, // 선택되지 않은 탭 색상
            indicatorColor: Colors.red, // 선택된 탭 아래 표시 색상
            tabs: [
              Tab(text: "랭킹"), // ✅ 첫 번째 탭 (랭킹)
              Tab(text: "컬렉션"), // ✅ 두 번째 탭 (컬렉션)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const RankingScreen(), // ✅ 랭킹 화면 (const 유지 가능)
            CollectionScreen(), // ✅ 컬렉션 화면 (const 제거)
          ],
        ),
      ),
    );
  }
}
