package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "collection_ingredients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CollectionIngredient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "collection_id", nullable = false)
    private Collection collection;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ingredient_id", nullable = false)
    private Ingredient ingredient;

    @Column(nullable = false)
    private int quantity;

    public CollectionIngredient(Collection collection, Ingredient ingredient, int quantity) {
        this.collection = collection;
        this.ingredient = ingredient;
        this.quantity = quantity;
    }
}
