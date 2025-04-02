package com.gachi_janchi.repository;

import com.gachi_janchi.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
  Optional<User> findByEmail(String email);
  Optional<User> findByNameAndEmail(String name, String email);
  boolean existsByEmail(String email);
  boolean existsByNickName(String nickName);
  boolean existsByNameAndIdAndEmail(String name, String id, String email);

  @Query("SELECT u FROM User u ORDER BY u.exp DESC")
  Page<User> findTopUsers(Pageable pageable);
}
