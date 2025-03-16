package com.gachi_janchi.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AddIngredientRequest {
    private String ingredientName; // 추가할 재료 이름
}
