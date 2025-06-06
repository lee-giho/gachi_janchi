package com.gachi_janchi.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetReviewByRestaurantIdResponse {
  List<ReviewWithImageAndMenu> reviews;
}
