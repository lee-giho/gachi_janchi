package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
  public ResponseEntity<GetReviewByRestaurantIdResponse> getReviewByRestaurantId(
    @RequestParam(name = "restaurantId") String restaurantId,
    @RequestParam(name = "sortType") String sortType,
    @RequestParam(name = "onlyImage") boolean onlyImage,
    @RequestParam(name = "page", defaultValue = "0") int page,
    @RequestParam(name = "size", defaultValue = "10") int size
  ) {
    GetReviewByRestaurantIdResponse getReviewByRestaurantIdResponse = reviewService.getReviewByRestaurant(restaurantId, sortType, onlyImage, page, size);
    return ResponseEntity.ok(getReviewByRestaurantIdResponse);
  }

  @GetMapping("/ratingStatus")
  public ResponseEntity<ReviewRatingStatusResponse> getReviewRatingStatus(@RequestParam(name = "restaurantId") String restaurantId) {
    ReviewRatingStatusResponse reviewRatingStatusResponse = reviewService.getReviewRatingStatus(restaurantId);
    return ResponseEntity.ok(reviewRatingStatusResponse);
  }

  @GetMapping("/userId")
  public ResponseEntity<GetReviewByUserIdResponse> getReviewByUserId(@RequestHeader("Authorization") String token, @RequestParam("sortType") String sortType) {
    GetReviewByUserIdResponse getReviewByUserIdResponse = reviewService.getReviewByUserId(token, sortType);
    return ResponseEntity.ok(getReviewByUserIdResponse);
  }

  @DeleteMapping("/reviewId")
  public ResponseEntity<DeleteReviewResponse> deleteReviewByReviewId(@RequestHeader("Authorization") String token, @RequestBody DeleteReviewRequest deleteReviewRequest) {
    DeleteReviewResponse deleteReviewResponse = reviewService.deleteReviewByReviewId(token, deleteReviewRequest);
    return ResponseEntity.ok(deleteReviewResponse);
  }

  @PatchMapping()
  public ResponseEntity<UpdateReviewResponse> updateReview(@RequestHeader("Authorization") String token, @ModelAttribute UpdateReviewRequest updateReviewRequest) {
    UpdateReviewResponse updateReviewResponse = reviewService.updateReview(token, updateReviewRequest);
    return ResponseEntity.ok(updateReviewResponse);
  }
  
}
