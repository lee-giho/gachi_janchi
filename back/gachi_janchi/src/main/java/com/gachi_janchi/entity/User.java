package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
public class User {

  @Id
  @Column(name = "id", nullable = false, unique = true)
  private String id;

  @Column(name = "name", nullable = false)
  private String name;

  @Column(name = "nick_name")
  private String nickName;

  @Column(name = "email")
  private String email;

  @Column(name = "type", nullable = false)
  private String type;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private LocalDateTime createdAt;

  // Role 정보 추가 (ManyToMany 관계)
  @ManyToMany(fetch = FetchType.EAGER)
  @JoinTable(
          name = "user_role",
          joinColumns = @JoinColumn(name = "user_id"),
          inverseJoinColumns = @JoinColumn(name = "role_name")
  )
  private Set<Role> roles = new LinkedHashSet<>();

  // ✅ 유저가 보유한 재료 (UserIngredient 연결)
  @OneToMany(mappedBy = "user", cascade = {CascadeType.PERSIST, CascadeType.MERGE}, fetch = FetchType.LAZY)
  private Set<UserIngredient> ingredients = new LinkedHashSet<>();
}
