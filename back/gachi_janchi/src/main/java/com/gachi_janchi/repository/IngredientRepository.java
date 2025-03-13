package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Ingredient;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientRepository extends JpaRepository<Ingredient, String> {
}
