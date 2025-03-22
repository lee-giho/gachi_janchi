package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CollectionIngredientDto {
    private String name;
    private int quantity;
    private String imagePath;
}
