package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class RestaurantsByBoundsResponse {
  private List<RestaurantWithIngredientAndReviewCountDto> restaurants;

}
