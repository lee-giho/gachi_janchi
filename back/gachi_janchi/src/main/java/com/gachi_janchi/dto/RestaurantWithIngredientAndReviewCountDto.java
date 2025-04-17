package com.gachi_janchi.dto;

import com.gachi_janchi.entity.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantWithIngredientAndReviewCountDto {
  private String id;
  private String restaurantName;
  private String imageUrl;
  private List<String> categories;
  private Address address;
  private Location location;
  private String phoneNumber;
  private Map<String, String> businessHours;
  private List<Menu> menu;
  private String ingredientName;
  private ReviewCountAndAvg reviewCountAndAvg;

  public static RestaurantWithIngredientAndReviewCountDto from(Restaurant restaurant, Ingredient ingredient, ReviewCountAndAvg reviewCountAndAvg) {
    return new RestaurantWithIngredientAndReviewCountDto(
            restaurant.getId(),
            restaurant.getRestaurantName(),
            restaurant.getImageUrl(),
            restaurant.getCategories(),
            restaurant.getAddress(),
            restaurant.getLocation(),
            restaurant.getPhoneNumber(),
            restaurant.getBusinessHours(),
            restaurant.getMenu(),
            ingredient != null ? ingredient.getName() : "재료 없음",
            reviewCountAndAvg
    );
  }
}
