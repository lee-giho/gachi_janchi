package com.gachi_janchi.dto;

import java.time.LocalDateTime;

import com.gachi_janchi.entity.Restaurant;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VisitedRestaurantDto {
  private Restaurant restaurant;
  private LocalDateTime visitedAt;
  private String ingredientName;
}
