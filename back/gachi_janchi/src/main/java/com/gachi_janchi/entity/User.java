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

  @Column(name = "profile_image_path")
  private String profileImagePath;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false,
          columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private LocalDateTime createdAt;

  // ✅ 대표 칭호 (nullable 허용, SET NULL 가능)
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "title_id", foreignKey = @ForeignKey(name = "fk_user_title"))
  private Title title;

  // ✅ Role 정보
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

  // ✅ 경험치 필드 추가
  @Column(name = "exp", nullable = false)
  private int exp = 0;

  // ✨ (선택) 유저가 완성한 컬렉션, 획득한 칭호 등도 연결 가능
}
