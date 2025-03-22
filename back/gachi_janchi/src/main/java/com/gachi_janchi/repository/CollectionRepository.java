package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Collection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CollectionRepository extends JpaRepository<Collection, Long> {
    Optional<Collection> findByName(String name);
    boolean existsByName(String name);
}
