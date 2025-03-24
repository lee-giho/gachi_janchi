package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "restaurant_ingredients")
public class RestaurantIngredient {
  @Id
  private String id;

  @Column(nullable = false, unique = true)
  private String restaurantId;

  @ManyToOne
  @JoinColumn(name = "ingredient_id", nullable = false)
  private Ingredient ingredient;
}
