package com.gachi_janchi.dto;

import com.querydsl.core.annotations.QueryProjection;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
public class ReviewWithWriterDto {
  private String reviewId;
  private String content;
  private int rating;
  private String type;
  private LocalDateTime createAt;

  private String userId;
  private String nickName;
  private String title;
  private String profileImage;

  private List<String> imageNames = new ArrayList<>();
  private List<String> menuNames = new ArrayList<>();

  @QueryProjection
  public ReviewWithWriterDto(
    String reviewId,
    String content,
    int rating,
    String type,
    LocalDateTime createAt,
    String userId,
    String nickName,
    String title,
    String profileImage
  ) {
    this.reviewId = reviewId;
    this.content = content;
    this.rating = rating;
    this.type = type;
    this.createAt = createAt;
    this.userId = userId;
    this.nickName = nickName;
    this.title = title;
    this.profileImage = profileImage;
  }
}
