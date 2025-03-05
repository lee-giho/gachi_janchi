package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.LinkedHashSet;
import java.util.Set;

@Data
@Entity
@Table(name = "users")
public class User {

//  @Id
//  @Column(name = "id")
//  @GeneratedValue(strategy = GenerationType.IDENTITY)
//  private Long id;
  @Id
  @Column(name = "id", nullable = false, unique = true)
  private String id;

//  @Column(name = "password", nullable = false)
//  private String password;

  @Column(name = "name", nullable = false)
  private String name;

  @Column(name = "nick_name", nullable = true)
  private String nickName;

  @Column(name = "email", nullable = true)
  private String email;

  @Column(name = "type", nullable = false)
  private String type;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private String createdAt;
  // Role 정보 추가 (ManyToMany 관계)
  @ManyToMany(fetch = FetchType.EAGER) // EAGER로 설정
  @JoinTable(
          name = "user_role",
          joinColumns = @JoinColumn(name = "user_id"),
          inverseJoinColumns = @JoinColumn(name = "role_name")
  )
  private Set<Role> roles = new LinkedHashSet<>();
}
