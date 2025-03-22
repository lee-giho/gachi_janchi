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

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @MapsId("ingredientId")
    @JoinColumn(name = "ingredient_id")
    private Ingredient ingredient;

    @Column(nullable = false)
    private int quantity;

    public UserIngredient(User user, Ingredient ingredient, int quantity) {
        this.id = new UserIngredientId(user.getId(), ingredient.getId());
        this.user = user;
        this.ingredient = ingredient;
        this.quantity = quantity;
    }
}
