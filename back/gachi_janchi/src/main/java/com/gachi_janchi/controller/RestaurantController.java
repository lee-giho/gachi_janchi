package com.gachi_janchi.controller;

import com.gachi_janchi.dto.GetIngredientByRestaurantIdResponse;
import com.gachi_janchi.dto.RestaurantsByBoundsResponse;
import com.gachi_janchi.dto.RestaurantsByDongResponse;
import com.gachi_janchi.dto.RestaurantsByKeywordResponse;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.service.RestaurantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/restaurant")
public class RestaurantController {
  @Autowired
  private RestaurantService restaurantService;

  // dong을 기준으로 Restaurant 리스트 가져오기
  @GetMapping("/dong")
  public ResponseEntity<RestaurantsByDongResponse> getRestaurantsByDong(@RequestParam("dong") String dong) {
    RestaurantsByDongResponse restaurantsByDongResponse = restaurantService.findRestaurantsByDong(dong);
    return ResponseEntity.ok(restaurantsByDongResponse);
  }

  // bounds를 기준으로 Restaurant 리스트 가져오기
  @GetMapping("/bounds")
  public ResponseEntity<RestaurantsByBoundsResponse> getRestaurantsByBounds(
    @RequestParam("latMin") double latMin,
    @RequestParam("latMax") double latMax,
    @RequestParam("lonMin") double lonMin,
    @RequestParam("lonMax") double lonMax
  ) {
    RestaurantsByBoundsResponse restaurantsByBoundsResponse = restaurantService.findRestaurantsInBounds(latMin, latMax, lonMin, lonMax);
    return ResponseEntity.ok(restaurantsByBoundsResponse);
  }

  // keyword로 Restaurant 검색해서 리스트 가져오기
  @GetMapping("/keyword")
  public ResponseEntity<RestaurantsByKeywordResponse> searchRestaurants(@RequestParam("keyword") String keyword) {
    RestaurantsByKeywordResponse restaurantsByKeywordResponse = restaurantService.findRestaurantsByKeyword(keyword);
    return ResponseEntity.ok(restaurantsByKeywordResponse);
  }

  // 음식점 id로 Restaurant 검색해서 정보 가져오기
  @GetMapping("/ingredientId")
  public ResponseEntity<GetIngredientByRestaurantIdResponse> getIngredientByRestaurantId(@RequestParam("restaurantId") String restaurantId) {
    GetIngredientByRestaurantIdResponse getRestaurantInfoByIdResponse = restaurantService.findIngredientByRestaurantId(restaurantId);
    return ResponseEntity.ok(getRestaurantInfoByIdResponse);
  }
  
}
