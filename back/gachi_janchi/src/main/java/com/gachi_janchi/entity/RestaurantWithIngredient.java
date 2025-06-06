package com.gachi_janchi.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantWithIngredient {
  private String id;
  private String restaurantName;
  private String imageUrl;
  private List<String> categories;
  private Address address;
  private Location location;
  private String phoneNumber;
  private Map<String, String> businessHours;
  private List<Menu> menu;
  private String ingredient;
}
