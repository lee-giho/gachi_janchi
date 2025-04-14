package com.gachi_janchi.dto;

import java.util.List;

import com.gachi_janchi.entity.Menu;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class GetRestaurantMenuResponse {
  private List<Menu> menu;
}
