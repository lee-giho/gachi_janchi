package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "users")
public class User {

//  @Id
//  @Column(name = "id")
//  @GeneratedValue(strategy = GenerationType.IDENTITY)
//  private Long id;
  @Id
  @Column(name = "email", nullable = false, unique = true)
  private String email;

//  @Column(name = "password", nullable = false)
//  private String password;

  @Column(name = "name", nullable = false)
  private String name;

  @Column(name = "phone_number", nullable = true)
  private String phoneNumber;

  @Column(name = "nick_name", nullable = true)
  private String nickName;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private String createdAt;
}
