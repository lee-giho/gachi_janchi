package com.gachi_janchi.repository;

import com.gachi_janchi.entity.TitleCondition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TitleConditionRepository extends JpaRepository<TitleCondition, Long> {
    boolean existsByTitleId(Long titleId);

    // ✅ 특정 칭호에 대한 모든 조건 조회
    Optional<TitleCondition> findByTitleId(Long titleId); // ← 이거 추가
}
