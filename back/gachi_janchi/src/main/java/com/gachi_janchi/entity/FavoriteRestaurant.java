package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "favorite_restaurant", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "restaurant_id"}) // 중복된 즐겨찾기 방지
})
public class FavoriteRestaurant {
  @Id
  private String id;

  @Column(name = "user_id", nullable = false)
  private String userId;

  @Column(name = "restaurant_id", nullable = false)
  private String restaurantId;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false)
  private LocalDateTime createdAt;

  // ✅ createdAt을 자동 생성하는 생성자 추가
  public FavoriteRestaurant(String id, String userId, String restaurantId) {
    this.id = id;
    this.userId = userId;
    this.restaurantId = restaurantId;
    this.createdAt = LocalDateTime.now(); // 자동 생성
  }
}