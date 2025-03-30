package com.gachi_janchi.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gachi_janchi.dto.AddReviewRequest;
import com.gachi_janchi.dto.AddReviewResponse;
import com.gachi_janchi.dto.GetReviewByRestaurantIdResponse;
import com.gachi_janchi.service.ReviewService;

import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;



@RestController
@RequestMapping("/api/review")
public class ReviewController {
  
  @Autowired
  private ReviewService reviewService;

  @PostMapping()
  public ResponseEntity<AddReviewResponse> addReview(@RequestHeader("Authorization") String token, @ModelAttribute AddReviewRequest addReviewRequest) {
    AddReviewResponse addReviewResponse = reviewService.addReview(token, addReviewRequest);
    return ResponseEntity.ok(addReviewResponse);
  }

  @GetMapping("/restaurantId")
  public ResponseEntity<GetReviewByRestaurantIdResponse> getReviewByRestaurantId(@RequestParam("restaurantId") String restaurantId) {
    GetReviewByRestaurantIdResponse getReviewByRestaurantIdResponse = reviewService.getReviewByRestaurant(restaurantId);
    return ResponseEntity.ok(getReviewByRestaurantIdResponse);
  }
  
}
