package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class AddVisitedRestaurantRequest {
  private String restaurantId;
  private Long ingredientId;
}
