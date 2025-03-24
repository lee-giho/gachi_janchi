package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data

@Entity
@Table(name = "title_conditions")
public class TitleCondition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // FK to Title
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "title_id", nullable = false)
    private Title title;

    @Column(name = "condition_type", nullable = false)
    private String conditionType; // 예: "DEFAULT", "COLLECTION", "INGREDIENT"

    @Column(name = "condition_value")
    private String conditionValue; // 예: "김치찌개", "5", "케이크,딸기"

    // 생성자
    public TitleCondition() {}

    public TitleCondition(Title title, String conditionType, String conditionValue) {
        this.title = title;
        this.conditionType = conditionType;
        this.conditionValue = conditionValue;
    }

    // Getter & Setter 생략 가능
}
