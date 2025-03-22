package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ingredients")
@Getter
@Setter
@NoArgsConstructor
public class Ingredient {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(name = "image_path")
    private String imagePath; // ✅ 이미지 경로 추가

    public Ingredient(String name, String imagePath) {
        this.name = name;
        this.imagePath = imagePath;
    }
}
