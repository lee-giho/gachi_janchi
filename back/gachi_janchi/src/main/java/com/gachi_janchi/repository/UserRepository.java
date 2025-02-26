package com.gachi_janchi.repository;

import com.gachi_janchi.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
  Optional<User> findByEmail(String email);
  Optional<User> findByNameAndEmail(String name, String email);
  boolean existsByEmail(String email);
  boolean existsByNickName(String nickName);
  boolean existsByNameAndIdAndEmail(String name, String id, String email);
}
