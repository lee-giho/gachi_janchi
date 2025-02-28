package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Restaurant;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface RestaurantRepository extends MongoRepository<Restaurant, String> {
  // 동을 기준으로 음식점들 찾기
  List<Restaurant> findByAddress_Dong(String dong);
}
