package com.gachi_janchi.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.VisitedRestaurant;
import java.util.List;

public interface VisitedRestaurantRepository extends JpaRepository<VisitedRestaurant, String> {
  // 특정 사용자의 방문한 음식점 리스트 가져오기
  List<VisitedRestaurant> findByUserId(String userId);
}
