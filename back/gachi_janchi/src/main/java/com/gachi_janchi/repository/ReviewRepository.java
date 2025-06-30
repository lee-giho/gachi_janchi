package com.gachi_janchi.repository;

import java.util.List;

import com.gachi_janchi.dto.ReviewCountAndAvg;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.gachi_janchi.entity.Review;

public interface ReviewRepository extends JpaRepository<Review, String>, ReviewRepositoryCustom{
  List<Review> findByRestaurantId(String restaurantId);

  Boolean existsByVisitedId(String visitedId);

  // 사용자 아이디로 리뷰 찾기 - 최신순
  List<Review> findAllByUserIdOrderByCreatedAtDesc(String userId);

  // 음식점 아이디로 찾은 리뷰 개수 반환
  int countByRestaurantId(String restaurantId);

  // 음식점 아이디로 찾은 리뷰의 평균값 반환
  @Query("SELECT AVG(r.rating) FROM Review r WHERE r.restaurantId = :restaurantId")
  Double findAverageRatingByRestaurantId(@Param("restaurantId") String restaurantId);
}
