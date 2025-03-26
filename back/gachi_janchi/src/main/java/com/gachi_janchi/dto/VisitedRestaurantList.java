package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VisitedRestaurantList {
  private List<VisitedRestaurantDto> visitedRestaurants;
}
