package com.gachi_janchi.repository;

import com.gachi_janchi.entity.LocalAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LocalAccountRepository extends JpaRepository<LocalAccount, String> {
//  Optional<LocalAccount> findByEmail(String email);

  boolean existsById(String Id);
}
