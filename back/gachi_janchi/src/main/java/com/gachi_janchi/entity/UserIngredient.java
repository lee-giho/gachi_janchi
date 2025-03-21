package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_ingredients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserIngredient {

    @EmbeddedId
    private UserIngredientId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("ingredientId")
    @JoinColumn(name = "ingredient_id", nullable = false)
    private Ingredient ingredient;

    @Column(name = "quantity", nullable = false)
    private int quantity;

    public UserIngredient(User user, Ingredient ingredient, int quantity) {
        this.id = new UserIngredientId(user.getId(), ingredient.getId());
        this.user = user;
        this.ingredient = ingredient;
        this.quantity = quantity;
    }

    /**
     * ✅ 재료 수량 차감 메서드
     * @param amount 차감할 수량
     * @throws IllegalArgumentException 재료 부족 시 예외 발생
     */
    public void decreaseQuantity(int amount) {
        if (this.quantity < amount) {
            throw new IllegalArgumentException("재료가 부족합니다: " + this.ingredient.getName());
        }
        this.quantity -= amount;
    }
}
