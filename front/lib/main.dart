import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:gachi_janchi/screens/splash_screen.dart';
import 'utils/screen_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 메소드에서 비동기 작업을 한 후에 runApp()을 실행할 경우에 상단에 추가해주는 코드
  await dotenv.load(fileName: ".env"); // .env 파일을 런타임에 가져오는 작업. 해당 작업을 통해 .env 파일에 작성한 구성 변수들을 사용할 수 있다.
  await NaverMapSdk.instance.initialize(clientId: "${dotenv.get("naver_map_client_id")}");
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
          home: const SplashScreen(),
        );

      }
    );
  }
}
