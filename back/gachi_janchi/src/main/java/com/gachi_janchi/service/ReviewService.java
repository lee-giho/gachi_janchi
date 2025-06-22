package com.gachi_janchi.service;

import java.io.File;
import java.io.IOException;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.gachi_janchi.entity.Review;
import com.gachi_janchi.entity.ReviewImage;
import com.gachi_janchi.entity.ReviewMenu;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.gachi_janchi.util.JwtProvider;
import java.nio.file.Files;


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

  @Autowired
  private UserService userService;

  @Value("${REVIEW_IMAGE_PATH}")
  private String reviewImageRelativePath;

  // 리뷰 저장
  @Transactional
  public AddReviewResponse addReview(String token, AddReviewRequest addReviewRequest) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String userId = jwtProvider.getUserId(accessToken);
    String reviewId = UUID.randomUUID().toString();
    
    String type = "text";

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
        type = "image";
      }

      // 리뷰 저장
      Review review = new Review(
        reviewId,
        userId,
        addReviewRequest.getVisitedId(),
        addReviewRequest.getRestaurantId(),
        addReviewRequest.getRating(),
        addReviewRequest.getContent(),
        type
      );
      reviewRepository.save(review);

      // 메뉴 저장
      if (addReviewRequest.getMenuNames() != null) {
        for (String menuName : addReviewRequest.getMenuNames()) {
          ReviewMenu reviewMenu = new ReviewMenu(
            UUID.randomUUID().toString(),
            menuName,
            review
          );
          reviewMenuRepository.save(reviewMenu);
        }
      }

      // 이미지 DB 저장
      for (String imageName : savedFileNames) {
        ReviewImage reviewImage = new ReviewImage(
          UUID.randomUUID().toString(),
          imageName,
          review
        );
        reviewImageRepository.save(reviewImage);
      }

      // 리뷰 작성 경험치 획득
      if (type.equals("image")) { // 이미지가 포함된 리뷰일 경우
        userService.gainExp(userId, 40);
      } else { // 이미지가 포함되지 않은 리뷰일 경우
        userService.gainExp(userId, 30);
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
      // throw new RuntimeException("리뷰 저장 중 오류 발생: " + e.getMessage(), e);
      throw new CustomException(ErrorCode.REVIEW_STORAGE_ERROR, "리뷰 저장 중 오류가 발생했습니다. - " + e.getMessage());
    }
  }

  // 음식점 ID로 리뷰 가져오기
  public GetReviewByRestaurantIdResponse getReviewByRestaurant(String restaurantId, String sortType, boolean onlyImage, int page, int size) {

    long start = System.currentTimeMillis();

    Pageable pageable = PageRequest.of(page, size);

    Page<ReviewWithWriterDto> dtoPage = reviewRepository.searchByRestaurantId(restaurantId, pageable, onlyImage, sortType);

    List<ReviewWithImageAndMenu> result = dtoPage.getContent().stream()
      .map(dto -> new ReviewWithImageAndMenu(
        new UserInfoWithProfileImageAndTitle(dto.getUserId(), dto.getNickName(), dto.getTitle(), dto.getProfileImage()),
        new Review(dto.getReviewId(), dto.getUserId(), null, restaurantId, dto.getRating(), dto.getContent(), dto.getType(), dto.getCreateAt()),
        dto.getImageNames().stream().map(img -> new ReviewImage(null, img, null)).collect(Collectors.toSet()),
        dto.getMenuNames().stream().map(menu -> new ReviewMenu(null, menu, null)).collect(Collectors.toSet())
      ))
      .toList();

    long end = System.currentTimeMillis();
    System.out.println("getReviewByRestaurant 실행 시간: " + (end - start) + "ms");

    return new GetReviewByRestaurantIdResponse(result, dtoPage.isLast());
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
        Set<ReviewImage> reviewImages = reviewImageRepository.findAllByReviewId(review.getId());
        Set<ReviewMenu> reviewMenus = reviewMenuRepository.findAllByReviewId(review.getId());
        User user = userRepository.findById(review.getUserId())
          // .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + review.getUserId()));
          .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        String titleName = (user.getTitle() != null) ? user.getTitle().getName() : null;
        return new ReviewWithImageAndMenu(
          new UserInfoWithProfileImageAndTitle(
            user.getId(), user.getNickName(), titleName, user.getProfileImage()
          ),
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
  public DeleteReviewResponse deleteReviewByReviewId(String token, DeleteReviewRequest deleteReviewRequest) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String userId = jwtProvider.getUserId(accessToken);

    String reviewId = deleteReviewRequest.getReviewId();

    // 리뷰 존재 여부 확인
    Review review = reviewRepository.findById(reviewId)
      // .orElseThrow(() -> new IllegalArgumentException("리뷰를 찾을 수 없습니다. - " + reviewId ));
      .orElseThrow(() -> new CustomException(ErrorCode.REVIEW_NOT_FOUND));

    // 리뷰 이미지 조회 및 파일 삭제
    Set<ReviewImage> reviewImages = reviewImageRepository.findAllByReviewId(reviewId);
    for (ReviewImage reviewImage : reviewImages) {
      String imagePath = reviewImageRelativePath + reviewImage.getImageName();
      File imageFile = new File(imagePath);
      if (imageFile.exists()) {
        boolean deleted = imageFile.delete();
        if (!deleted) {
          throw new CustomException(ErrorCode.FILE_DELETE_ERROR);
        }
      }
    }

    // 리뷰 메뉴 DB 삭제
    Set<ReviewMenu> reviewMenus = reviewMenuRepository.findAllByReviewId(reviewId);
    reviewMenuRepository.deleteAll(reviewMenus);

    // 리뷰 이미지 DB 삭제
    reviewImageRepository.deleteAll(reviewImages);

    // 리뷰 DB 삭제
    reviewRepository.delete(review);

    // 리뷰 작성 경험치 차감
    if (review.getType().equals("image")) { // 이미지가 포함된 리뷰일 경우
      userService.gainExp(userId, -40);
    } else { // 이미지가 포함되지 않은 리뷰일 경우
      userService.gainExp(userId, -30);
    }

    return new DeleteReviewResponse("Delete Review Successful");
  }

  // 리뷰 업데이트
  @Transactional
  public UpdateReviewResponse updateReview(String token, UpdateReviewRequest updateReviewRequest) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(accessToken);

    Review review = reviewRepository.findById(updateReviewRequest.getReviewId())
      // .orElseThrow(() -> new IllegalArgumentException("리뷰를 찾을 수 없습니다."));
      .orElseThrow(() -> new CustomException(ErrorCode.REVIEW_NOT_FOUND));

    String originalType = review.getType();
    String changeType = "";

    // 이미지 저장 경로
    List<File> savedFiles = new ArrayList<>();
    List<String> savedFileNames = new ArrayList<>();

    List<File> removedFiles = new ArrayList<>();
    List<File> backFiles = new ArrayList<>();
    List<String> removeImageNames = new ArrayList<>();

    try {
      // 추가된 이미지 파일 저장
      if (updateReviewRequest.getChangeImages() != null) {
        for (MultipartFile image : updateReviewRequest.getChangeImages()) {
          String imageFileName = UUID.randomUUID().toString() + "_" + image.getOriginalFilename();
          String fullPath = reviewImageRelativePath + imageFileName;

          File dest = new File(fullPath);
          dest.getParentFile().mkdirs(); // 디렉토리 없으면 생성
          image.transferTo(dest); // 이미지 저장
          
          savedFiles.add(dest);
          savedFileNames.add(imageFileName); // DB 저장용 이름
        }
      }

      // 기존 이미지 파일 삭제
      if (updateReviewRequest.getRemoveOriginalImageNames() != null) {
        // 리뷰 이미지 조회 및 파일 삭제
        Set<ReviewImage> reviewImages = reviewImageRepository.findAllByReviewId(updateReviewRequest.getReviewId());

        // 저장되어 있는 사진 이름
        List<String> savedImageNames = reviewImages.stream()
          .map(ReviewImage::getImageName)
          .collect(Collectors.toList());
        
        removeImageNames = new ArrayList<>(updateReviewRequest.getRemoveOriginalImageNames());
        
        if (savedImageNames.containsAll(removeImageNames)) { // 요청 받은 removeOriginalImageNames가 DB에 존재하면
          for (String removeImageName : removeImageNames) {
            String imagePath = reviewImageRelativePath + removeImageName;
            String imageBackUpPath = reviewImageRelativePath + "backUp/" + removeImageName;
  
  
            File imageFile = new File(imagePath);
            File backUpFile = new File(imageBackUpPath);
  
            backUpFile.getParentFile().mkdirs(); // backup 폴더 없으면 생성
            Files.copy(imageFile.toPath(), backUpFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
  
            if (imageFile.exists()) {
              boolean deleted = imageFile.delete();
              if (!deleted) {
                System.out.println("이미지 삭제 실패 - " + imagePath);

              }
              removedFiles.add(imageFile);
              backFiles.add(backUpFile);
            }
          }
        }
      }

      // 메뉴 변경 (삭제 후 재등록)
      if (updateReviewRequest.getChangeMenus() != null) {
        Set<ReviewMenu> reviewMenus = reviewMenuRepository.findAllByReviewId(updateReviewRequest.getReviewId());

        // 저장되어 있는 메뉴 이름
        List<String> savedMenuNames = reviewMenus.stream()
          .map(ReviewMenu::getMenuName)
          .collect(Collectors.toList());

        // 삭제할 메뉴 이름
        List<String> deleteMenuNames = new ArrayList<>(savedMenuNames);
        deleteMenuNames.removeAll(updateReviewRequest.getChangeMenus());
        
        // 저장할 메뉴 이름
        List<String> saveMenuNames = new ArrayList<>(updateReviewRequest.getChangeMenus());
        saveMenuNames.removeAll(savedMenuNames);
        saveMenuNames.remove("remove all");

        // 메뉴 삭제
        if (!deleteMenuNames.isEmpty()) {
          for (String menuName : deleteMenuNames) {
            reviewMenuRepository.deleteByReviewIdAndMenuName(updateReviewRequest.getReviewId(), menuName);
          }
        }
        
        // 메뉴 저장
        if (!saveMenuNames.isEmpty()){
          for (String menuName : saveMenuNames) {
            ReviewMenu reviewMenu = new ReviewMenu(
              UUID.randomUUID().toString(),
              menuName,
              review
            );
            reviewMenuRepository.save(reviewMenu);
          }
        }
      }

      // 내용 수정
      if (updateReviewRequest.getChangeContent() != null) {
        review.setContent(updateReviewRequest.getChangeContent());
      }

      // 별점 수정
      if (updateReviewRequest.getChangeRating() != 0) {
        review.setRating(updateReviewRequest.getChangeRating());
      }

      // 기존 이미지 DB 삭제
      if (!removeImageNames.isEmpty()) {
        for (String imageName : removeImageNames) {
          reviewImageRepository.deleteByReviewIdAndImageName(updateReviewRequest.getReviewId(), imageName);
        }
      }

      // 추가된 이미지 DB 저장
      if (!savedFileNames.isEmpty()) {
        for (String imageName : savedFileNames) {
          ReviewImage reviewImage = new ReviewImage(
            UUID.randomUUID().toString(),
            imageName,
            review
          );
          reviewImageRepository.save(reviewImage);
        }
      }

      if (reviewImageRepository.existsByReviewId(updateReviewRequest.getReviewId())) { // 이미지 삭제/추가 처리 후 계속 이미지가 존재할 때 - image 타입 유지
        changeType = "image";
      } else { // 이미지가 존재하지 않을 때 - text 타입으로 변경
        changeType = "text";
      }

      if (originalType.equals("image")) { // 기존 타입이 image일 경우
        if (changeType.equals("image")) { // 타입이 image -> image로 유지된 경우
          System.out.println("기존 타입 유지: " + originalType + " -> " + changeType);
        } else { // 타입이 image -> text로 변경된 경우
          System.out.println("타입 변경: " + originalType + " -> " + changeType);
          review.setType(changeType);
          userService.gainExp(userId, -10); // 이미지 리뷰와 텍스트 리뷰 경험치 차이만큼 차감
        }
      } else { // 기존 타입이 text일 경우
        if (changeType.equals("image")) { // 타입이 text -> image로 변경된 경우
          System.out.println("타입 변경: " + originalType + " -> " + changeType);
          review.setType(changeType);
          userService.gainExp(userId, 10); // 이미지 리뷰와 텍스트 리뷰 경험치 차이만큼 획득
        } else { // 타입이 text -> text로 유지된 경우
          System.out.println("기존 타입 유지: " + originalType + " -> " + changeType);
        }
      }
      
      reviewRepository.save(review);

      if (!removedFiles.isEmpty()) {
        for (int i = 0; i < backFiles.size(); i++) {
          File backup = backFiles.get(i);

          backup.delete(); // 저장 후 백업 파일 삭제
        }
      }

      return new UpdateReviewResponse("리뷰가 정상적으로 수정되었습니다.");

    } catch(Exception e) {
      // 예외 발생 시, 저장했던 파일들 삭제
      if (!savedFiles.isEmpty()) {
        for (File file : savedFiles) {
          if (file.exists()) {
            file.delete();
          }
        }
      }

      if (!removedFiles.isEmpty()) {
        for (int i = 0; i < backFiles.size(); i++) {
          File deleted = removedFiles.get(i);
          File backup = backFiles.get(i);

          try {
              Files.copy(backup.toPath(), deleted.toPath(), StandardCopyOption.REPLACE_EXISTING);
              backup.delete(); // 백업 파일은 복원 후 삭제
          } catch (IOException ioException) {
              System.out.println("백업 이미지 복원 실패 - " + deleted.getName());
              ioException.printStackTrace();
          }
        }
      }
      
      // throw new RuntimeException("리뷰 저장 중 오류 발생: " + e.getMessage(), e);
      throw new CustomException(ErrorCode.REVIEW_UPDATE_ERROR, "리뷰 수정 중 오류가 발생했습니다. - " + e.getMessage());
    }
  }

  public ReviewRatingStatusResponse getReviewRatingStatus(String restaurantId) {
    long start = System.currentTimeMillis();

    ReviewRatingStatusResponse reviewRatingStatusResponse = reviewRepository.getRatingStatusByRestaurantId(restaurantId);

    long end = System.currentTimeMillis();
    System.out.println("getReviewByRestaurant 실행 시간: " + (end - start) + "ms");

    return reviewRatingStatusResponse;
  }

  private Sort getSortBySortType(String sortType) {
    return switch (sortType) {
      case "latest" -> Sort.by(Sort.Direction.DESC, "createdAt");
      case "earliest" -> Sort.by(Sort.Direction.ASC, "createdAt");
      case "highRating" -> Sort.by(Sort.Direction.DESC, "rating");
      case "lowRating" -> Sort.by(Sort.Direction.ASC, "rating");
      default -> throw new CustomException(ErrorCode.INVALID_SORT_TYPE);
    };
  }
}
