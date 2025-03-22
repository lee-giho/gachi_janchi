package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class CollectionResponse {
    private String name;
    private String imagePath;
    private String description;
    private List<CollectionIngredientDto> ingredients;
}
