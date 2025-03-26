package com.gachi_janchi.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "visited_restaurant")
public class VisitedRestaurant {
  @Id
  private String id;

  @Column(name = "user_id", nullable = false)
  private String userId;

  @Column(name = "restaurant_id", nullable = false)
  private String restaurantId;

  @Column(name = "ingredient_id", nullable = false)
  private Long ingredientId;

  @Column(name = "visited_at", nullable = false, updatable = false, insertable = false)
  private LocalDateTime visitedAt;

  // visitedAt을 자동 생성하는 생성자 추가
  public VisitedRestaurant(String id, String userId, String restaurantId, Long ingredientId) {
    this.id = id;
    this.userId = userId;
    this.restaurantId = restaurantId;
    this.ingredientId = ingredientId;
    this.visitedAt = LocalDateTime.now();
  }
}
