package com.gachi_janchi.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.Review;

public interface ReviewRepository extends JpaRepository<Review, String>{
  Boolean existsByVisitedId(String visitedId); 

  // 음식점 아이디로 리뷰 찾기
  List<Review> findAllByRestaurantId(String restaurantId);
}
