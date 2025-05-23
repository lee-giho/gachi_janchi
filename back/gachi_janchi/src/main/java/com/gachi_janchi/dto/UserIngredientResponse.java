package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class UserIngredientResponse {
    private String ingredientName; // ✅ 재료 이름
    private int quantity;          // ✅ 보유 개수
}
