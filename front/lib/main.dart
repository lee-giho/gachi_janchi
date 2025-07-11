import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/screens/splash_screen.dart';
import 'package:gachi_janchi/utils/navigatorObserver.dart';
import 'utils/screen_size.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // main 메소드에서 비동기 작업을 한 후에 runApp()을 실행할 경우에 상단에 추가해주는 코드
  await dotenv.load(
      fileName:
          ".env"); // .env 파일을 런타임에 가져오는 작업. 해당 작업을 통해 .env 파일에 작성한 구성 변수들을 사용할 수 있다.
  // await NaverMapSdk.instance
  //     .initialize(clientId: "${dotenv.get("naver_map_client_id")}");
  await FlutterNaverMap().init(
    clientId: "${dotenv.get("naver_map_client_id")}",
    onAuthFailed: (ex) => switch (ex) {
      NQuotaExceededException(:final message) => print("사용량 초과 (message: $message)"),
      NUnauthorizedClientException() ||
      NClientUnspecifiedException() ||
      NAnotherAuthFailedException() => print("인증 실패: $ex")
    },
  );
  runApp(ProviderScope(child: MyApp())); // Riverpod 사용
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // ScreenSize 초기화
      ScreenSize()
          .init(width: constraints.maxWidth, height: constraints.maxHeight);

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [MyNavigatorObserver()],
        title: 'Flutter Login',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, // 기본 배경색을 흰색으로 설정
          colorScheme: ColorScheme.light(), // 기본 컬러 스킴을 밝은 모드로 설정
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      );
    });
  }
}
