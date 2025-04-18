package com.gachi_janchi.dto;

import java.util.List;
import java.util.Map;

import com.gachi_janchi.entity.Address;
import com.gachi_janchi.entity.Location;
import com.gachi_janchi.entity.Menu;
import com.gachi_janchi.entity.Restaurant;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RestaurantDetailInfo {
  private String id;
  private String restaurantName;
  private String imageUrl;
  private List<String> categories;
  private Address address;
  private Location location;
  private String phoneNumber;
  private Map<String, String> businessHours;
  private List<Menu> menu;
  private ReviewCountAndAvg reviewCountAndAvg;

  public static RestaurantDetailInfo from (Restaurant restaurant, ReviewCountAndAvg reviewCountAndAvg) {
    return new RestaurantDetailInfo(
      restaurant.getId(),
      restaurant.getRestaurantName(),
      restaurant.getImageUrl(),
      restaurant.getCategories(),
      restaurant.getAddress(),
      restaurant.getLocation(),
      restaurant.getPhoneNumber(),
      restaurant.getBusinessHours(),
      restaurant.getMenu(),
      reviewCountAndAvg
    );
  }
}
