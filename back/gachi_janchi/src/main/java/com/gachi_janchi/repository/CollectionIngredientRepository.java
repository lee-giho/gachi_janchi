package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Collection;
import com.gachi_janchi.entity.CollectionIngredient;
import com.gachi_janchi.entity.Ingredient;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CollectionIngredientRepository extends JpaRepository<CollectionIngredient, Long> {
    boolean existsByCollectionAndIngredient(Collection collection, Ingredient ingredient);
}
