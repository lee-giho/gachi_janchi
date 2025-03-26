package com.gachi_janchi.repository;

import com.gachi_janchi.entity.RestaurantIngredient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RestaurantIngredientRepository extends JpaRepository<RestaurantIngredient, String> {
  Optional<RestaurantIngredient> findByRestaurantId(String restaurantId);
  void deleteByRestaurantId(String restaurantId);
}
