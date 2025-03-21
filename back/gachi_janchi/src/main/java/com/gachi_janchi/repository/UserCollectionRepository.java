package com.gachi_janchi.repository;

import com.gachi_janchi.entity.UserCollection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserCollectionRepository extends JpaRepository<UserCollection, Long> {
    List<UserCollection> findByUserId(String userId);
}
