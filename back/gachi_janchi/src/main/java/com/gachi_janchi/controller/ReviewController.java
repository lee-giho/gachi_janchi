package com.gachi_janchi.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gachi_janchi.dto.AddReviewRequest;
import com.gachi_janchi.dto.AddReviewResponse;
import com.gachi_janchi.dto.DeleteReviewRequest;
import com.gachi_janchi.dto.DeleteReviewResponse;
import com.gachi_janchi.dto.GetReviewByRestaurantIdResponse;
import com.gachi_janchi.dto.GetReviewByUserIdResponse;
import com.gachi_janchi.dto.UpdateReviewRequest;
import com.gachi_janchi.dto.UpdateReviewResponse;
import com.gachi_janchi.service.ReviewService;

import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.DeleteMapping;
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
  public ResponseEntity<GetReviewByRestaurantIdResponse> getReviewByRestaurantId(@RequestParam("restaurantId") String restaurantId, @RequestParam("sortType") String sortType) {
    GetReviewByRestaurantIdResponse getReviewByRestaurantIdResponse = reviewService.getReviewByRestaurant(restaurantId, sortType);
    return ResponseEntity.ok(getReviewByRestaurantIdResponse);
  }

  @GetMapping("/userId")
  public ResponseEntity<GetReviewByUserIdResponse> getReviewByUserId(@RequestHeader("Authorization") String token, @RequestParam("sortType") String sortType) {
    GetReviewByUserIdResponse getReviewByUserIdResponse = reviewService.getReviewByUserId(token, sortType);
    return ResponseEntity.ok(getReviewByUserIdResponse);
  }

  @DeleteMapping("/reviewId")
  public ResponseEntity<DeleteReviewResponse> deleteReviewByReviewId(@RequestBody DeleteReviewRequest deleteReviewRequest) {
    DeleteReviewResponse deleteReviewResponse = reviewService.deleteReviewByReviewId(deleteReviewRequest);
    return ResponseEntity.ok(deleteReviewResponse);
  }

  @PatchMapping()
  public ResponseEntity<UpdateReviewResponse> updateReview(@ModelAttribute UpdateReviewRequest updateReviewRequest) {
    UpdateReviewResponse updateReviewResponse = reviewService.updateReview(updateReviewRequest);
    return ResponseEntity.ok(updateReviewResponse);
  }
  
}
