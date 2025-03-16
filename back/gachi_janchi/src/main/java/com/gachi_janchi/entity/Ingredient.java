package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor // ✅ JPA 기본 생성자
@Table(name = "ingredients")
public class Ingredient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, unique = true)
    private String name;

    // ✅ 이름을 받는 생성자 추가
    public Ingredient(String name) {
        this.name = name;
    }
}
