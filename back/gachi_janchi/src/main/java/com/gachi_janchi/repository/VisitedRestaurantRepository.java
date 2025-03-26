package com.gachi_janchi.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.VisitedRestaurant;

public interface VisitedRestaurantRepository extends JpaRepository<VisitedRestaurant, String> {
  
}
