package com.gachi_janchi.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.gachi_janchi.entity.Review;

public interface ReviewRepository extends JpaRepository<Review, String>{
  Boolean existsByVisitedId(String visitedId); 

  // 음식점 아이디로 리뷰 찾기 - 최신순
  List<Review> findAllByRestaurantIdOrderByCreatedAtDesc(String restaurantId);

  // 사용자 아이디로 리뷰 찾기 - 최신순
  List<Review> findAllByUserIdOrderByCreatedAtDesc(String userId);

  // 음식점 아이디로 찾은 리뷰 개수 반환
  int countByRestaurantId(String restaurantId);

  // 음식점 아이디로 찾은 리뷰의 평균값 반환
  @Query("SELECT AVG(r.rating) FROM Review r WHERE r.restaurantId = :restaurantId")
  Double findAverageRatingByRestaurantId(@Param("restaurantId") String restaurantId);
}
