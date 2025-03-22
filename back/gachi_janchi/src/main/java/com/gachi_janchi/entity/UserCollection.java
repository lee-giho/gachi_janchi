package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_collections")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserCollection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "collection_id")
    private Collection collection;

    private LocalDateTime acquiredAt;

    public UserCollection(User user, Collection collection) {
        this.user = user;
        this.collection = collection;
        this.acquiredAt = LocalDateTime.now();
    }
}
