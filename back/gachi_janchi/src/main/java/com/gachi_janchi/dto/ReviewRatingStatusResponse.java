package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ReviewRatingStatusResponse {
  private int rating_1;
  private int rating_2;
  private int rating_3;
  private int rating_4;
  private int rating_5;
}
