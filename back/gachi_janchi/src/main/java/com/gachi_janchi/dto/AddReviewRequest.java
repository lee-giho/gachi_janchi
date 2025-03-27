package com.gachi_janchi.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AddReviewRequest {
  private String restaurantId;
  private int rating;
  private String content;
  private List<String> menuNames; // 선택적
  private List<MultipartFile> images; // 선택적
}
