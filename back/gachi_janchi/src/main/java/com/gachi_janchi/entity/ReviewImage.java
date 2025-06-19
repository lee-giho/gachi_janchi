package com.gachi_janchi.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "review_image")
public class ReviewImage {
  @Id
  private String id;

  @Column(name = "image_name", nullable = false)
  private String imageName;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "review_id")
  @ToString.Exclude
  @EqualsAndHashCode.Exclude
  @JsonBackReference
  private Review review;
}
