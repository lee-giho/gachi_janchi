package com.gachi_janchi.repository;

import com.gachi_janchi.entity.UserIngredient;
import com.gachi_janchi.entity.UserIngredientId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserIngredientRepository extends JpaRepository<UserIngredient, UserIngredientId> {
    List<UserIngredient> findByUserId(String userId);
    Optional<UserIngredient> findByUserIdAndIngredientId(String userId, Long ingredientId);
}
