package com.gachi_janchi.entity;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "review", uniqueConstraints = {
  @UniqueConstraint(columnNames = {"user_id", "visited_id"}) // 중복된 리뷰 방지
})
public class Review {
  @Id
  @Column(name = "id")
  private String id;

  @Column(name = "user_id", nullable = false)
  private String userId;

  @Column(name = "visited_id", nullable = false)
  private String visitedId;

  @Column(name = "restaurant_id", nullable = false)
  private String restaurantId;

  @Column(name = "rating", nullable = false)
  private int rating;

  @Column(name = "content", nullable = false)
  private String content;

  @Column(name = "type", nullable = false)
  private String type;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false)
  private LocalDateTime createdAt;

  @OneToMany(mappedBy = "review", fetch = FetchType.LAZY)
  @JsonManagedReference
  private Set<ReviewImage> reviewImages = new HashSet<>();

  @OneToMany(mappedBy = "review", fetch = FetchType.LAZY)
  @JsonManagedReference
  private Set<ReviewMenu> reviewMenus = new HashSet<>();

  public Review(String id, String userId, String visitedId, String restaurantId, int rating, String content, String type) {
    this.id = id;
    this.userId = userId;
    this.visitedId = visitedId;
    this.restaurantId = restaurantId;
    this.rating = rating;
    this.content = content;
    this.type = type;
    this.createdAt = LocalDateTime.now();
  }

  public Review(String id, String userId, String visitedId, String restaurantId, int rating, String content, String type, LocalDateTime createdAt) {
    this.id = id;
    this.userId = userId;
    this.visitedId = visitedId;
    this.restaurantId = restaurantId;
    this.rating = rating;
    this.content = content;
    this.type = type;
    this.createdAt = createdAt;
  }
}
