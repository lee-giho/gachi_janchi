package com.gachi_janchi.event;

import lombok.Data;

@Data
public class ReviewUpdateEvent {
  private final String restaurantId;
}
