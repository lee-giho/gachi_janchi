import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; // 로그인 화면으로 이동하기 위한 import

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = ''; // 비밀번호 확인 오류 메시지

  // 회원가입 요청 처리
  Future<void> _signup() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 입력하세요")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다'; // 비밀번호 불일치 오류 메시지
      });
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 상태 활성화
      _errorMessage = ''; // 오류 메시지 초기화
    });

    final url = "http://localhost:8080/api/auth/register"; // 서버 API 주소

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // JSON 데이터
        },
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
          "name": _nameController.text,
        }),
      );

      setState(() {
        _isLoading = false; // 로딩 상태 비활성화
      });

      if (response.statusCode == 200) {
        // 회원가입 성공 시 팝업 띄우고, 확인 버튼을 눌러 로그인 화면으로 이동
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('회원가입 성공'),
              content: const Text('회원가입이 성공적으로 완료되었습니다. 로그인 화면으로 이동합니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(), // 로그인 화면으로 이동
                      ),
                    );
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입 실패: ${response.body}")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _signup, // 회원가입 함수 호출
              child: const Text('회원가입'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
