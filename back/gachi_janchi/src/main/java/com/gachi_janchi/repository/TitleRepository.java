package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Title;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TitleRepository extends JpaRepository<Title, Long> {
    boolean existsByName(String name);
    Optional<Title> findByName(String name);
}
