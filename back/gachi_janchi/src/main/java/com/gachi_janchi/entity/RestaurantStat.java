package com.gachi_janchi.entity;

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
@Table(name = "restaurant_stat")
public class RestaurantStat {

  @Id
  @Column(name = "restaurant_id", nullable = false)
  private String restaurantId;

  @Column(name = "review_count", nullable = false)
  private long reviewCount;

  @Column(name = "average_rating", nullable = false)
  private double averageRating;
}
