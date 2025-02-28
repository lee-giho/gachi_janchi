package com.gachi_janchi.controller;

import com.gachi_janchi.dto.RestaurantsByDongResponse;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.service.RestaurantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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
}
