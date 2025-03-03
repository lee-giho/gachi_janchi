package com.gachi_janchi.entity;

import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "restaurants")
public class Restaurant {
  @Id
  private String id;
  private String restaurantName;
  private String imageUrl;
  private List<String> categories;
  private Address address;
  private Location location;
  private String phoneNumber;
  private Map<String, String> businessHours;
  private Map<String, String> menu;
}

