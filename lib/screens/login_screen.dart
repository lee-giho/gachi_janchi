import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 필드
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 필드
  bool _isLoading = false; // 로딩 상태 관리

  // 로그인 요청 처리
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 입력하세요")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 상태 활성화
    });

    final url = "http://localhost:8080/api/auth/login"; // 8080 포트로 설정

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // JSON 데이터
        },
        body: jsonEncode({
          "email": _emailController.text, // 이메일 입력 값으로 수정
          "password": _passwordController.text, // 비밀번호 입력 값
        }),
      );

      setState(() {
        _isLoading = false; // 로딩 상태 비활성화
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 성공")),
        );

        // 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // 로딩 상태 비활성화
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  // 회원가입 화면으로 이동
  void _navigateToSignup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );

    // 회원가입 후 돌아오면 로그인 화면 초기화
    setState(() {
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  void dispose() {
    // 화면 종료 시 텍스트 필드 초기화
    _emailController.clear();
    _passwordController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress, // 이메일 형식
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true, // 비밀번호 입력 시 텍스트 숨김
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator()) // 로딩 표시
                : ElevatedButton(
              onPressed: _login, // 로그인 함수 호출
              child: const Text('로그인'),
            ),
            const SizedBox(height: 20),
            // 회원가입 버튼
            TextButton(
              onPressed: _navigateToSignup, // 회원가입 화면으로 이동
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
