package com.gachi_janchi.repository;

import com.gachi_janchi.entity.UserIngredient;
import com.gachi_janchi.entity.UserIngredientId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

public interface UserIngredientRepository extends JpaRepository<UserIngredient, UserIngredientId> {
    List<UserIngredient> findByUserId(String userId);
    Optional<UserIngredient> findByUserIdAndIngredientId(String userId, Long ingredientId);

    // ✅ JPA가 감지 못할 경우 직접 업데이트 실행
    @Modifying
    @Transactional
    @Query("UPDATE UserIngredient u SET u.quantity = :quantity WHERE u.user.id = :userId AND u.ingredient.id = :ingredientId")
    void updateIngredientQuantity(String userId, Long ingredientId, int quantity);

}
