package com.gachi_janchi.controller;

import com.gachi_janchi.dto.GetFavoriteCountResponse;
import com.gachi_janchi.dto.GetIngredientByRestaurantIdResponse;
import com.gachi_janchi.dto.GetRestaurantMenuResponse;
import com.gachi_janchi.dto.RestaurantDetailScreenResponse;
import com.gachi_janchi.dto.RestaurantsByBoundsResponse;
import com.gachi_janchi.dto.RestaurantsByKeywordResponse;
import com.gachi_janchi.service.FavoriteRestaurantService;
import com.gachi_janchi.service.RestaurantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/restaurant")
public class RestaurantController {
  @Autowired
  private RestaurantService restaurantService;

  @Autowired
  private FavoriteRestaurantService favoriteRestaurantService;

  // dong을 기준으로 Restaurant 리스트 가져오기
  // @GetMapping("/dong")
  // public ResponseEntity<RestaurantsByDongResponse> getRestaurantsByDong(@RequestParam("dong") String dong) {
  //   RestaurantsByDongResponse restaurantsByDongResponse = restaurantService.findRestaurantsByDong(dong);
  //   return ResponseEntity.ok(restaurantsByDongResponse);
  // }

  // bounds를 기준으로 Restaurant 리스트 가져오기
  @GetMapping("/bounds")
  public ResponseEntity<RestaurantsByBoundsResponse> getRestaurantsByBounds(
    @RequestParam("latMin") double latMin,
    @RequestParam("latMax") double latMax,
    @RequestParam("lonMin") double lonMin,
    @RequestParam("lonMax") double lonMax
  ) {
    System.out.println("현재 작업 디렉토리: " + System.getProperty("user.dir"));
    RestaurantsByBoundsResponse restaurantsByBoundsResponse = restaurantService.findRestaurantsInBounds(latMin, latMax, lonMin, lonMax);
    return ResponseEntity.ok(restaurantsByBoundsResponse);
  }

  // keyword로 Restaurant 검색해서 리스트 가져오기
  @GetMapping("/keyword")
  public ResponseEntity<RestaurantsByKeywordResponse> searchRestaurants(@RequestParam("keyword") String keyword) {
    RestaurantsByKeywordResponse restaurantsByKeywordResponse = restaurantService.findRestaurantsByKeyword(keyword);
    return ResponseEntity.ok(restaurantsByKeywordResponse);
  }

  // 음식점 id로 Restaurant 정보 반환 엔드포인트
  @GetMapping("/restaurantId")
  public ResponseEntity<RestaurantDetailScreenResponse> getRestaurantInfo(@RequestParam("restaurantId") String restaurantId) {
    RestaurantDetailScreenResponse restaurantDetailScreenResponse = restaurantService.findRestaurantByRestaurantId(restaurantId);
    return ResponseEntity.ok(restaurantDetailScreenResponse);
  }
  


  // 음식점 id로 재료 반환 엔드포인트
  @GetMapping("/ingredientId")
  public ResponseEntity<GetIngredientByRestaurantIdResponse> getIngredientByRestaurantId(@RequestParam("restaurantId") String restaurantId) {
    GetIngredientByRestaurantIdResponse getRestaurantInfoByIdResponse = restaurantService.findIngredientByRestaurantId(restaurantId);
    return ResponseEntity.ok(getRestaurantInfoByIdResponse);
  }
  
  // 음식점별 즐겨찾기 수 반환 엔드포인트
  @GetMapping("/count")
  public ResponseEntity<GetFavoriteCountResponse> getFavoriteCount(@RequestParam("restaurantId") String restaurantId) {
    GetFavoriteCountResponse getFavoriteCount = favoriteRestaurantService.getFavoriteCount(restaurantId);
    return ResponseEntity.ok(getFavoriteCount);
  }
  
  // 음식점 메뉴 반환 엔드포인트
  @GetMapping("/menu")
  public ResponseEntity<GetRestaurantMenuResponse> getRestaurantMenu(@RequestParam("restaurantId") String restaurantId) {
    GetRestaurantMenuResponse getRestaurantMenuResponse = restaurantService.getRestaurantMenuByRestaurantId(restaurantId);
    return ResponseEntity.ok(getRestaurantMenuResponse);
  }

}
