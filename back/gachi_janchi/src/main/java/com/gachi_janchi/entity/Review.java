package com.gachi_janchi.entity;

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
@Table(name = "review")
public class Review {
  @Id
  @Column(name = "id")
  private String id;

  @Column(name = "user_id", nullable = false)
  private String userId;

  @Column(name = "restaurant_id", nullable = false)
  private String restaurantId;

  @Column(name = "rating", nullable = false)
  private int rating;

  @Column(name = "content", nullable = false)
  private String content;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false)
  private LocalDateTime createdAt;

  // createdAt을 자동 생성하는 생성자 추가
  public Review(String id, String userId, String restaurantId, int rating, String content) {
    this.id = id;
    this.userId = userId;
    this.restaurantId = restaurantId;
    this.rating = rating;
    this.content = content;
    this.createdAt = LocalDateTime.now();
  }
  
}
