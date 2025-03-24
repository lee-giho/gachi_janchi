package com.gachi_janchi.service;

import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.RestaurantIngredient;
import com.gachi_janchi.repository.RestaurantIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class IngredientService {
  private final RestaurantIngredientRepository restaurantIngredientRepository;

  public Ingredient findIngredientByRestaurantId(String restaurantId) {
    Optional<RestaurantIngredient> restaurantIngredient = restaurantIngredientRepository.findByRestaurantId(restaurantId);
    return restaurantIngredient.map(RestaurantIngredient::getIngredient).orElse(null);
  }
}
