package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "collections")
@Getter
@Setter
@NoArgsConstructor // 기본 생성자 추가 (JPA 필수)
@AllArgsConstructor // 모든 필드를 받는 생성자 추가
public class Collection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @OneToMany(mappedBy = "collection", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<CollectionIngredient> ingredients = new HashSet<>();

    public Collection(String name) {
        this.name = name;
    }
}
