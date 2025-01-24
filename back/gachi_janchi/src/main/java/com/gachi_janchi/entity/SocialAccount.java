package com.gachi_janchi.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "social_account")
public class SocialAccount {
  @Id
  @Column(name = "email", nullable = false, unique = true)
  private String email;

  @Column(name = "provider", nullable = false)
  private String provider;
}
