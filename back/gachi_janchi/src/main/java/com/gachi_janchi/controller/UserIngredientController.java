package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.service.UserIngredientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ingredients")

public class UserIngredientController {

    @Autowired
    private UserIngredientService userIngredientService;

    /**
     * ✅ 재료 추가 API (획득)
     */
    @PostMapping("/add")
    public ResponseEntity<AddIngredientResponse> addIngredient(
            @RequestHeader("Authorization") String accessToken,
            @RequestBody AddIngredientRequest request) {

        AddIngredientResponse response = userIngredientService.addIngredient(accessToken, request);
        return ResponseEntity.ok(response);
    }
    // 전체 재료 목록 조회
    @GetMapping("/all")
    public ResponseEntity<List<IngredientResponse>> getAllIngredients() {
        return ResponseEntity.ok(userIngredientService.getAllIngredients());
    }
    /**
     * ✅ 유저가 보유한 재료 목록 조회 API
     */
    @GetMapping("/user")
    public ResponseEntity<List<UserIngredientResponse>> getUserIngredients(
            @RequestHeader("Authorization") String accessToken) {

        List<UserIngredientResponse> response = userIngredientService.getUserIngredients(accessToken);
        return ResponseEntity.ok(response);
    }
}
