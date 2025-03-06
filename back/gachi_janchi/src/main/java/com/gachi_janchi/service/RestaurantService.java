package com.gachi_janchi.service;

import com.gachi_janchi.dto.RestaurantsByBoundsResponse;
import com.gachi_janchi.dto.RestaurantsByDongResponse;
import com.gachi_janchi.dto.RestaurantsByKeywordResponse;
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

  // 지도에 보이는 영역을 기준으로 Restaurant 찾기
  public RestaurantsByBoundsResponse findRestaurantsInBounds(double latMin, double latMax, double lonMin, double lonMax) {
    List<Restaurant> restaurants = restaurantRepository.findByLocationLatitudeBetweenAndLocationLongitudeBetween(latMin, latMax, lonMin, lonMax);
    return new RestaurantsByBoundsResponse(restaurants);
  }

  public RestaurantsByKeywordResponse findRestaurantsByKeyword(String keyword) {
    List<Restaurant> restaurants = restaurantRepository.searchRestaurants(keyword);
    return new RestaurantsByKeywordResponse(restaurants);
  }
}
