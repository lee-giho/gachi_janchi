package com.gachi_janchi.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gachi_janchi.entity.ReviewMenu;

public interface ReviewMenuRepository extends JpaRepository<ReviewMenu, String> {
  // 리뷰 ID로 메뉴 리스트 찾기
  List<ReviewMenu> findAllByReviewId(String reviewId);

  // 리뷰 id와 menuName으로 삭제하기
  void deleteByReviewIdAndMenuName(String reviewId, String menuName);
}
