package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.service.TitleService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/titles")
@RequiredArgsConstructor
public class TitleController {

    private final TitleService titleService;

    @GetMapping
    public ResponseEntity<List<TitleResponse>> getAllTitles() {
        return ResponseEntity.ok(titleService.getAllTitles());
    }

    @GetMapping("/user")
    public ResponseEntity<List<UserTitleResponse>> getUserTitles(
            @RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(titleService.getUserTitles(token));
    }

    @PostMapping("/set")
    public ResponseEntity<Void> changeUserTitle(
            @RequestHeader("Authorization") String token,
            @RequestBody ChangeUserTitleRequest request) {
        titleService.changeUserTitle(token, request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/claim")
    public ResponseEntity<Void> claimTitle(
            @RequestHeader("Authorization") String token,
            @RequestBody ClaimTitleRequest request) {
        titleService.claimTitle(token, request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/conditions")
    public ResponseEntity<List<TitleConditionResponse>> getTitleConditions() {
        return ResponseEntity.ok(titleService.getAllTitleConditions());
    }

    @GetMapping("/progress")
    public ResponseEntity<List<TitleConditionProgressResponse>> getUserTitleProgress(
            @RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(titleService.getUserTitleProgress(token));
    }
}
