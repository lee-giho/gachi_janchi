package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewCountAndAvg {
  private String restaurantId;
  private long reviewCount;
  private double reviewAvg;
}
