package com.gachi_janchi.dto;

import com.gachi_janchi.entity.Restaurant;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class RestaurantsByKeywordResponse {
  private List<RestaurantWithIngredientAndReviewCountDto> restaurants;
}
