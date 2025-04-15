package com.gachi_janchi.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UpdateReviewRequest {
  private String reviewId;
  private List<String> removeOriginalImageNames;
  private List<MultipartFile> changeImages;
  private List<String> changeMenus;
  private String changeContent;
  private int changeRating;
}
