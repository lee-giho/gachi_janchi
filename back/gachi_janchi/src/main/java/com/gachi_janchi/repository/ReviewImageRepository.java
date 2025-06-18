package com.gachi_janchi.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.ReviewImage;

public interface ReviewImageRepository extends JpaRepository<ReviewImage, String> {

  List<ReviewImage> findAllByReviewIdIn(List<String> reviewIds);

  // 리뷰 ID로 이미지 리스트 찾기
  List<ReviewImage> findAllByReviewId(String reviewId);

  // 리뷰 id와 menuName으로 삭제하기
  void deleteByReviewIdAndImageName(String reviewId, String imageName);

  Boolean existsByReviewId(String reviewId);
}
