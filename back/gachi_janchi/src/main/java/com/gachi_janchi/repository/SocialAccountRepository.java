package com.gachi_janchi.repository;

import com.gachi_janchi.entity.SocialAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SocialAccountRepository extends JpaRepository<SocialAccount, String> {
  Optional<SocialAccount> findByEmail(String email);
  boolean existsByEmail(String email);
}
