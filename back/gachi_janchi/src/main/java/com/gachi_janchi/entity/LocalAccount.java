package com.gachi_janchi.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "local_account")
public class LocalAccount {
  @Id
  @Column(name = "id", nullable = false, unique = true)
  private String id;

  @Column(name = "password", nullable = false)
  private String password;

  @Column(name = "email", nullable = false)
  private String email;
}
