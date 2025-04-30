package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Restaurant;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface RestaurantRepository extends MongoRepository<Restaurant, String>, CustomRestaurantRepository {
  // 동을 기준으로 음식점들 찾기
  List<Restaurant> findByAddress_Dong(String dong);

  // 보여지는 지도 범위에 있는 음식점들 찾기
  List<Restaurant> findByLocationLatitudeBetweenAndLocationLongitudeBetween(double latMin, double latMax, double lonMin, double lonMax);
}
