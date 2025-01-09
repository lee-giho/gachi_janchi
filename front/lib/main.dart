import 'package:flutter/material.dart';
import 'utils/screen_size.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ScreenSize 초기화
        ScreenSize().init(
          width: constraints.maxWidth,
          height: constraints.maxHeight
        );
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Login',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginScreen(),
        );

      }
    );
  }
}
