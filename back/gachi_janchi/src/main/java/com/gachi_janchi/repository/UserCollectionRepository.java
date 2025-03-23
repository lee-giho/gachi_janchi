package com.gachi_janchi.repository;

import com.gachi_janchi.entity.Collection;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.entity.UserCollection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserCollectionRepository extends JpaRepository<UserCollection, Long> {
    // 유저가 획득한 컬렉션 수 (진행도 계산용)
    int countByUserId(String userId);
    // ✅ 유저 ID로 컬렉션 조회
    List<UserCollection> findByUserId(String userId);

    // ✅ 특정 유저가 특정 컬렉션을 이미 완성했는지 확인
    boolean existsByUserAndCollection(User user, Collection collection);
}
