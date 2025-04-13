package com.gachi_janchi.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.gachi_janchi.dto.AddReviewRequest;
import com.gachi_janchi.dto.AddReviewResponse;
import com.gachi_janchi.dto.DeleteReviewRequest;
import com.gachi_janchi.dto.DeleteReviewResponse;
import com.gachi_janchi.dto.GetReviewByRestaurantIdResponse;
import com.gachi_janchi.dto.GetReviewByUserIdResponse;
import com.gachi_janchi.dto.ReviewWithImageAndMenu;
import com.gachi_janchi.dto.UserInfoWithProfileImageAndTitle;
import com.gachi_janchi.entity.Review;
import com.gachi_janchi.entity.ReviewImage;
import com.gachi_janchi.entity.ReviewMenu;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.ReviewImageRepository;
import com.gachi_janchi.repository.ReviewMenuRepository;
import com.gachi_janchi.repository.ReviewRepository;
import com.gachi_janchi.repository.UserRepository;
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

  @Autowired
  private UserRepository userRepository;

  @Value("${REVIEW_IMAGE_PATH}")
  private String reviewImageRelativePath;

  // 리뷰 저장
  @Transactional
  public AddReviewResponse addReview(String token, AddReviewRequest addReviewRequest) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String userId = jwtProvider.getUserId(accessToken);
    String reviewId = UUID.randomUUID().toString();
    
    // 이미지 저장 경로
    List<File> savedFiles = new ArrayList<>();
    List<String> savedFileNames = new ArrayList<>();

    try {
      // 이미지 파일 저장
      if (addReviewRequest.getImages() != null) {
        for (MultipartFile image : addReviewRequest.getImages()) {
          String imageFileName = UUID.randomUUID().toString() + "_" + image.getOriginalFilename();
          String fullPath = reviewImageRelativePath + imageFileName;

          File dest = new File(fullPath);
          dest.getParentFile().mkdirs(); // 디렉토리 없으면 생성
          image.transferTo(dest); // 이미지 저장
          
          savedFiles.add(dest);
          savedFileNames.add(imageFileName); // DB 저장용 이름
        }
      }

      // 리뷰 저장
      Review review = new Review(
        reviewId,
        userId,
        addReviewRequest.getVisitedId(),
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

      // 이미지 DB 저장
      for (String imageName : savedFileNames) {
        ReviewImage reviewImage = new ReviewImage(
          UUID.randomUUID().toString(),
          reviewId,
          imageName
        );
        reviewImageRepository.save(reviewImage);
      }

      return new AddReviewResponse("리뷰가 정상적으로 저장되었습니다.");
    } catch (Exception e) {
      // 예외 발생 시, 저장했던 파일들 삭제
      if (!savedFiles.isEmpty()) {
        for (File file : savedFiles) {
          if (file.exists()) {
            file.delete();
          }
        }
      }
      throw new RuntimeException("리뷰 저장 중 오류 발생: " + e.getMessage(), e);
    }
  }

  // 음식점 ID로 리뷰 가져오기
  public GetReviewByRestaurantIdResponse getReviewByRestaurant(String restaurantId, String sortType) {
    // 음식점에 대한 리뷰 다 가져오기
    List<Review> reviewList = new ArrayList<>();

    if (sortType.equals("latest")) {
      reviewList = reviewRepository.findAllByRestaurantIdOrderByCreatedAtDesc(restaurantId);
    }

    List<ReviewWithImageAndMenu> reviewWithImageAndMenus = reviewList.stream()
      .map(review -> {
        List<ReviewImage> reviewImages = reviewImageRepository.findAllByReviewId(review.getId());
        List<ReviewMenu> reviewMenus = reviewMenuRepository.findAllByReviewId(review.getId());
        User user = userRepository.findById(review.getUserId()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + review.getUserId()));
        String titleName = (user.getTitle() != null) ? user.getTitle().getName() : null;
        return new ReviewWithImageAndMenu(new UserInfoWithProfileImageAndTitle(
          user.getId(), titleName, user.getProfileImage()),
          review,
          reviewImages,
          reviewMenus
        );
      })
      .collect(Collectors.toList());

    return new GetReviewByRestaurantIdResponse(reviewWithImageAndMenus);
  }

  // 사용자 Id로 리뷰 가져오기
  public GetReviewByUserIdResponse getReviewByUserId(String token, String sortType) {
    // 음식점에 대한 리뷰 다 가져오기
    List<Review> reviewList = new ArrayList<>();

    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String userId = jwtProvider.getUserId(accessToken);

    if (sortType.equals("latest")) {
      reviewList = reviewRepository.findAllByUserIdOrderByCreatedAtDesc(userId);
    }

    List<ReviewWithImageAndMenu> reviewWithImageAndMenus = reviewList.stream()
      .map(review -> {
        List<ReviewImage> reviewImages = reviewImageRepository.findAllByReviewId(review.getId());
        List<ReviewMenu> reviewMenus = reviewMenuRepository.findAllByReviewId(review.getId());
        User user = userRepository.findById(review.getUserId()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + review.getUserId()));
        String titleName = (user.getTitle() != null) ? user.getTitle().getName() : null;
        return new ReviewWithImageAndMenu(new UserInfoWithProfileImageAndTitle(
          user.getId(), titleName, user.getProfileImage()),
          review,
          reviewImages,
          reviewMenus
        );
      })
      .collect(Collectors.toList());

    return new GetReviewByUserIdResponse(reviewWithImageAndMenus);
  }

  // 리뷰 ID로 삭제하기
  @Transactional
  public DeleteReviewResponse deleteReviewByReviewId(DeleteReviewRequest deleteReviewRequest) {
    String reviewId = deleteReviewRequest.getReviewId();

    // 리뷰 존재 여부 확인
    Review review = reviewRepository.findById(reviewId).orElseThrow(() -> new IllegalArgumentException("리뷰를 찾을 수 없습니다. - " + reviewId ));

    // 리뷰 이미지 조회 및 파일 삭제
    List<ReviewImage> reviewImages = reviewImageRepository.findAllByReviewId(reviewId);
    for (ReviewImage reviewImage : reviewImages) {
      String imagePath = reviewImageRelativePath + reviewImage.getImageName();
      File imageFile = new File(imagePath);
      if (imageFile.exists()) {
        boolean deleted = imageFile.delete();
        if (!deleted) {
          System.out.println("이미지 삭제 실패 - " + imagePath);
        }
      }
    }

    // 리뷰 메뉴 DB 삭제
    List<ReviewMenu> reviewMenus = reviewMenuRepository.findAllByReviewId(reviewId);
    reviewMenuRepository.deleteAll(reviewMenus);

    // 리뷰 이미지 DB 삭제
    reviewImageRepository.deleteAll(reviewImages);

    // 리뷰 DB 삭제
    reviewRepository.delete(review);

    return new DeleteReviewResponse("Delete Review Successful");
  }
}
