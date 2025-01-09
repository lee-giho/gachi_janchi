import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // ScreenSize 값 가져오기
  final screenWidth = ScreenSize().width;
  final screenHeight = ScreenSize().height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(

        ),
      ),
    );
  }
}