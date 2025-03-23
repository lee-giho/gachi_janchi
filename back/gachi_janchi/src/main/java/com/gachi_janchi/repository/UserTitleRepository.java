package com.gachi_janchi.repository;

import com.gachi_janchi.entity.UserTitle;
import com.gachi_janchi.entity.UserTitleId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserTitleRepository extends JpaRepository<UserTitle, UserTitleId> {
    List<UserTitle> findByUserId(String userId);
    boolean existsByUserIdAndTitleId(String userId, Long titleId);
}
