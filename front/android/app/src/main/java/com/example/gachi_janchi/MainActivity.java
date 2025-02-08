package com.example.gachi_janchi;

import android.os.Bundle; // ✅ Bundle import 추가
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) { // ✅ Bundle 오류 해결
        // intent.putExtra("background_mode", "transparent");
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onBackPressed() { // ✅ 올바른 방식으로 뒤로 가기 버튼 처리
        super.onBackPressed();
    }
}
