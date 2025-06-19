package com.gachi_janchi.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "review_menu")
public class ReviewMenu {
  @Id
  @Column(name = "id")
  private String id;

  @Column(name = "menu_name", nullable = false)
  private String menuName;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "review_id")
  @ToString.Exclude
  @EqualsAndHashCode.Exclude
  @JsonBackReference
  private Review review;
}
