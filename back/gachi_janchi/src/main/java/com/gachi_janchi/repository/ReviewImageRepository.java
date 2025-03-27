package com.gachi_janchi.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.ReviewImage;

public interface ReviewImageRepository extends JpaRepository<ReviewImage, String> {
  
}
