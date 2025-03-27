package com.gachi_janchi.service;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.gachi_janchi.dto.AddReviewRequest;
import com.gachi_janchi.dto.AddReviewResponse;
import com.gachi_janchi.entity.Review;
import com.gachi_janchi.entity.ReviewImage;
import com.gachi_janchi.entity.ReviewMenu;
import com.gachi_janchi.repository.ReviewImageRepository;
import com.gachi_janchi.repository.ReviewMenuRepository;
import com.gachi_janchi.repository.ReviewRepository;
import com.gachi_janchi.util.JwtProvider;

@Service
public class ReviewService {

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private ReviewRepository reviewRepository;

  @Autowired
  private ReviewMenuRepository reviewMenuRepository;

  @Autowired
  private ReviewImageRepository reviewImageRepository;

  @Value("${REVIEW_IMAGE_PATH}")
  private String reviewImageRelativePath;

  // 리뷰 저장
  @Transactional
  public AddReviewResponse addReview(String token, AddReviewRequest addReviewRequest) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String userId = jwtProvider.getUserId(accessToken);
    String reviewId = UUID.randomUUID().toString();
    System.out.println("메뉴: " + addReviewRequest.getMenuNames());
    System.out.println("사진: " + addReviewRequest.getImages());
    // 리뷰 저장
    Review review = new Review(
      reviewId,
      userId,
      addReviewRequest.getRestaurantId(),
      addReviewRequest.getRating(),
      addReviewRequest.getContent() 
    );
    reviewRepository.save(review);

    // 메뉴 저장
    if (addReviewRequest.getMenuNames() != null) {
      for (String menuName : addReviewRequest.getMenuNames()) {
        ReviewMenu reviewMenu = new ReviewMenu(
          UUID.randomUUID().toString(),
          reviewId,
          menuName
        );
        reviewMenuRepository.save(reviewMenu);
      }
    }

    // 이미지 저장
    if (addReviewRequest.getImages() != null) {
      for (MultipartFile image : addReviewRequest.getImages()) {
        String imageFileName = UUID.randomUUID().toString() + "_" + image.getOriginalFilename();
        String fullPath = reviewImageRelativePath + imageFileName;

        File dest = new File(fullPath);
        dest.getParentFile().mkdirs(); // 디렉토리 없으면 생성
        try {
          image.transferTo(dest);
        } catch (IOException e) {
          throw new RuntimeException("이미지 저장 실패" + image.getOriginalFilename(), e);
        }

        ReviewImage reviewImage = new ReviewImage(
          UUID.randomUUID().toString(),
          reviewId,
          imageFileName
        );
        reviewImageRepository.save(reviewImage);
      }
    }

    return new AddReviewResponse("이미지 저장을 완료했습니다.");
  }
}
