package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RestaurantDetailScreenResponse {
  private RestaurantDetailInfo restaurant;
}
