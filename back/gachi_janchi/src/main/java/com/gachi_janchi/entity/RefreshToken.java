package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "refresh_tokens")
public class RefreshToken {

  @Id
  @Column(name = "id")
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "email", nullable = false)
  private String email; // 외래키

  @Column(name = "token", nullable = false, unique = true)
  private String token;

  @Column(name = "expiration", nullable = false)
  private long expiration;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private String createdAt;
}
