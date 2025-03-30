package com.gachi_janchi.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class AddReviewRequest {
  private String visitedId;
  private String restaurantId;
  private int rating;
  private String content;
  private List<String> menuNames; // 선택적
  private List<MultipartFile> images; // 선택적
}
