package com.gachi_janchi.dto;

import com.gachi_janchi.entity.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantWithIngredientAndReviewCountDto {
  private String id;
  private String restaurantName;
  private String imageUrl;
  private Location location;
  private Map<String, String> businessHours;
  private String ingredientName;
  private ReviewCountAndAvg reviewCountAndAvg;

  public static RestaurantWithIngredientAndReviewCountDto from(Restaurant restaurant, Ingredient ingredient, ReviewCountAndAvg reviewCountAndAvg) {
    return new RestaurantWithIngredientAndReviewCountDto(
            restaurant.getId(),
            restaurant.getRestaurantName(),
            restaurant.getImageUrl(),
            restaurant.getLocation(),
            restaurant.getBusinessHours(),
            ingredient != null ? ingredient.getName() : "재료 없음",
            reviewCountAndAvg
    );
  }
}
