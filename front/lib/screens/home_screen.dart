import 'package:flutter/material.dart';
import '../utils/secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // String accessToken = SecureStorage.getAccessToken();

  void clickBtn() async {
    String? accessToken = await SecureStorage.getAccessToken();
    String? refreshToken = await SecureStorage.getRefreshToken();
    print("accessToken: ${accessToken}");
    print("refreshToken: ${refreshToken}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Center(
            child: Column(
              children: [
                const Text("홈 화면"),
                ElevatedButton(
                  onPressed: () {
                    clickBtn();
                  },
                  child: Text("토큰 확인")
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}