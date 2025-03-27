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
@Table(name = "review_menu")
public class ReviewMenu {
  @Id
  @Column(name = "id")
  private String id;

  @Column(name = "review_id", nullable = false)
  private String reviewId;

  @Column(name = "menu_name", nullable = false)
  private String menuName;
}
