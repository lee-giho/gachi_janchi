package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Restaurant;

import java.util.List;

public interface CustomRestaurantRepository {
  List<Restaurant> searchRestaurants(String keyword);
}
