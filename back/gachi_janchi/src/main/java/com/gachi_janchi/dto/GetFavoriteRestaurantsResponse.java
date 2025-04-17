package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class GetFavoriteRestaurantsResponse {
  //  List<String> favoriteRestaurants;
  private List<RestaurantWithIngredientAndReviewCountDto> restaurants;
}
