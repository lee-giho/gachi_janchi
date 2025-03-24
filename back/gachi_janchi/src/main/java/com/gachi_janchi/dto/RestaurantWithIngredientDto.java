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
public class RestaurantWithIngredientDto {
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

  public static RestaurantWithIngredientDto from(Restaurant restaurant, Ingredient ingredient) {
    return new RestaurantWithIngredientDto(
            restaurant.getId(),
            restaurant.getRestaurantName(),
            restaurant.getImageUrl(),
            restaurant.getCategories(),
            restaurant.getAddress(),
            restaurant.getLocation(),
            restaurant.getPhoneNumber(),
            restaurant.getBusinessHours(),
            restaurant.getMenu(),
            ingredient != null ? ingredient.getName() : "재료 없음"
    );
  }
}
