package com.gachi_janchi.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.EqualsAndHashCode;

import java.util.Set;

@Entity
@Table(name = "roles")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true) // equals 및 hashCode 명시적 설정
public class Role {

    @Id
    @Column(name = "role_name", nullable = false, unique = true)
    @EqualsAndHashCode.Include
    private String roleName;

    @ManyToMany(mappedBy = "roles")
    private Set<User> users;
}
