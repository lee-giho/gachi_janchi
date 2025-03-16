package com.gachi_janchi.entity;

import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserIngredientId implements Serializable {
    private String userId;
    private Long ingredientId;
}
