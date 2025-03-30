package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DeleteFavoriteRestaurantRequest {
  private String restaurantId;
}
