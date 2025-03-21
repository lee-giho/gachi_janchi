package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Collection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CollectionRepository extends JpaRepository<Collection, Long> {
    Optional<Collection> findByName(String name);  // ✅ 컬렉션 이름으로 조회
    boolean existsByName(String name);  // ✅ 존재 여부 확인 (추가)
}
