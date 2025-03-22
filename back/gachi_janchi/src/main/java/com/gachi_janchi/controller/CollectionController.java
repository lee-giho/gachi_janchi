package com.gachi_janchi.controller;

import com.gachi_janchi.dto.CollectionCompleteRequest;
import com.gachi_janchi.dto.CollectionResponse;
import com.gachi_janchi.dto.UserCollectionResponse;
import com.gachi_janchi.service.CollectionService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/collections")
@RequiredArgsConstructor
public class CollectionController {

    private final CollectionService collectionService;

    // ✅ 전체 컬렉션 목록 조회
    @GetMapping
    public List<CollectionResponse> getCollections(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        return collectionService.getAllCollections(token);
    }

    // ✅ 유저가 완성한 컬렉션 목록 조회
    @GetMapping("/user")
    public List<UserCollectionResponse> getUserCollections(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        return collectionService.getUserCollections(token);
    }

    // ✅ 컬렉션 완성 요청
    @PostMapping("/complete")
    public String completeCollection(
            HttpServletRequest request,
            @RequestBody CollectionCompleteRequest completeRequest) {
        String token = request.getHeader("Authorization");
        return collectionService.completeCollection(token, completeRequest);
    }
}
