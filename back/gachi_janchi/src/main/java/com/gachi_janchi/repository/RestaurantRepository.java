package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Restaurant;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface RestaurantRepository extends MongoRepository<Restaurant, String> {
  Optional<Restaurant> findByRestaurantName(String restaurantName);
}
