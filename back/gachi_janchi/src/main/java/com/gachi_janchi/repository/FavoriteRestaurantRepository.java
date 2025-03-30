package com.gachi_janchi.repository;

import com.gachi_janchi.entity.FavoriteRestaurant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRestaurantRepository extends JpaRepository<FavoriteRestaurant, String> {
  // 특정 사용자가 특정 음식점을 즐겨찾기 했는지 확인
  Optional<FavoriteRestaurant> findByUserIdAndRestaurantId(String userId, String restaurantId);

  // 특정 사용자의 즐겨찾기 목록 가져오기
  List<FavoriteRestaurant> findByUserId(String userId);

  // 특정 즐겨찾기 삭제
  void deleteByUserIdAndRestaurantId(String userId, String restaurantId);

  // 음식점 즐겨찾기 수 가져오기
  Long countByRestaurantId(String restaurantId);
}
