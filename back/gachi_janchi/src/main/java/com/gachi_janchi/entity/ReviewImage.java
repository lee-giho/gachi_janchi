package com.gachi_janchi.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "review_image")
public class ReviewImage {
  @Id
  private String id;

  @Column(name = "review_id", nullable = false)
  private String reviewId;

  @Column(name = "image_name", nullable = false)
  private String imageName;
}
