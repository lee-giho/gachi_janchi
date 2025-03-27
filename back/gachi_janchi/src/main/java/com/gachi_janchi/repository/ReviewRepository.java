package com.gachi_janchi.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.Review;

public interface ReviewRepository extends JpaRepository<Review, String>{
  
}
