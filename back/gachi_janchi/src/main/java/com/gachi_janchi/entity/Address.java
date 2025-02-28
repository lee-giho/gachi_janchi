package com.gachi_janchi.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Address {
  private String sido;
  private String sigungu;
  private String dong;
  private String roadName;
  private String buildingNumber;
}
