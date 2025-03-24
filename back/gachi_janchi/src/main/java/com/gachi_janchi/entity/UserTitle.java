package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
@Data

@Entity
@Table(name = "user_titles")
@IdClass(UserTitleId.class)
public class UserTitle {

    @Id
    @Column(name = "user_id")
    private String userId;

    @Id
    @ManyToOne
    @JoinColumn(name = "title_id")
    private Title title;

    @Column(name = "acquired_at")
    private LocalDateTime acquiredAt = LocalDateTime.now();

    public UserTitle() {}

    public UserTitle(String userId, Title title) {
        this.userId = userId;
        this.title = title;
    }

    // Getter & Setter 생략 가능
}
