package com.gachi_janchi.controller;

import com.gachi_janchi.dto.CollectionCompleteRequest;
import com.gachi_janchi.dto.UserCollectionResponse;
import com.gachi_janchi.service.CollectionService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/collections")
public class CollectionController {

    private final CollectionService collectionService;

    public CollectionController(CollectionService collectionService) {
        this.collectionService = collectionService;
    }

    @PostMapping("/complete")
    public String completeCollection(@RequestHeader("Authorization") String accessToken,
                                     @RequestBody CollectionCompleteRequest request) {
        return collectionService.completeCollection(accessToken, request);
    }

    @GetMapping("/user")
    public List<UserCollectionResponse> getUserCollections(@RequestHeader("Authorization") String accessToken) {
        return collectionService.getUserCollections(accessToken);
    }
}
