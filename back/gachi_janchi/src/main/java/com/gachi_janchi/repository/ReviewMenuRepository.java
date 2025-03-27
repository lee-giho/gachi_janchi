package com.gachi_janchi.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.ReviewMenu;

public interface ReviewMenuRepository extends JpaRepository<ReviewMenu, String> {
  
}
