package com.gachi_janchi.service;

import com.gachi_janchi.dto.RestaurantsByBoundsResponse;
import com.gachi_janchi.dto.RestaurantsByDongResponse;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.repository.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RestaurantService {
  @Autowired
  private RestaurantRepository restaurantRepository;

  // dong을 기준으로 Restaurant 찾기
  public RestaurantsByDongResponse findRestaurantsByDong(String dong) {
    List<Restaurant> restaurants = restaurantRepository.findByAddress_Dong(dong);
    return new RestaurantsByDongResponse(restaurants);
  }

  private double calculateRadius(double zoom) {
    if (zoom > 16) return 0.005; // 줌 레벨이 높을수록 작은 범위 검색
    if (zoom > 14) return 0.01;
    if (zoom > 12) return 0.05;
    return 0.1; // 줌 레벨이 낮을 수록 넓은 범위 검색
  }

  public RestaurantsByBoundsResponse findRestaurantsInBounds(double latitude, double longitude, double zoom) {
    // 줌 레벨에 따라 검색 반경 조절
    double radius = calculateRadius(zoom);
    double latMin = latitude - radius;
    double latMax = latitude + radius;
    double lonMin = longitude - radius;
    double lonMax = longitude + radius;

    List<Restaurant> restaurants = restaurantRepository.findByLocationLatitudeBetweenAndLocationLongitudeBetween(latMin, latMax, lonMin, lonMax);

    return new RestaurantsByBoundsResponse(restaurants);
  }
}
