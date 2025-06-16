package com.gachi_janchi.repository;

import com.gachi_janchi.dto.ReviewCountAndAvg;
import com.gachi_janchi.entity.RestaurantStat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RestaurantStatRepository extends JpaRepository<RestaurantStat, String> {
  @Query("""
      SELECT new com.gachi_janchi.dto.ReviewCountAndAvg(
        rs.restaurantId,
        rs.reviewCount,
        rs.averageRating
      )
      FROM RestaurantStat rs
      WHERE rs.restaurantId IN :restaurantIds
    """)
  List<ReviewCountAndAvg> findReviewStatsByRestaurantIds(@Param("restaurantIds") List<String> restaurantIds);
}
