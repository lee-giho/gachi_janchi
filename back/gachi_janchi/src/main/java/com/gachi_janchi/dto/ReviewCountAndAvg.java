package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ReviewCountAndAvg {
  private int reviewCount;
  private Double reviewAvg;
}
