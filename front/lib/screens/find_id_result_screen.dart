import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gachi_janchi/screens/login_screen.dart';

class FindIdResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  
  const FindIdResultScreen({super.key, required this.data});
  

  @override
  State<FindIdResultScreen> createState() => _FindIdResultScreenState();
}

class _FindIdResultScreenState extends State<FindIdResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container( // 전체화면
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                        child: Text(
                          "${widget.data['name']}님의 아이디",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color:Colors.black),
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromARGB(255, 255, 249, 230)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.data['id'],
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: widget.data['id']));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("아이디가 복사되었습니다."))
                                      );
                                    }
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                )
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  child: const Text(
                    "로그인 화면으로 이동",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
              )
            ],

          ),
        )
      ),
    );
  }
}