import 'package:flutter/material.dart';
import 'package:gachi_janchi/widgets/VisitedRestaurantTile.dart';

class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key});

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container( // 전체 화면
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            children: [
              const Align( // 페이지 타이틀
                alignment: Alignment.topLeft,
                child: Text(
                  "방문내역",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
              VisitedRestaurantTile()
            ],
          ),
        )
      )
    );
  }
}