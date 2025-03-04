import 'package:flutter/material.dart';

class EdittitleScreen extends StatelessWidget {
  const EdittitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("칭호 수정")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "칭호 수정 기능은 추후 제작.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 뒤로가기
              },
              child: const Text("확인"),
            ),
          ],
        ),
      ),
    );
  }
}
