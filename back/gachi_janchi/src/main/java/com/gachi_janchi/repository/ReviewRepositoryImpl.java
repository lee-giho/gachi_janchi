package com.gachi_janchi.repository;

import com.gachi_janchi.dto.QReviewWithWriterDto;
import com.gachi_janchi.dto.ReviewWithWriterDto;
import com.gachi_janchi.entity.*;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.querydsl.core.types.Order;
import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RequiredArgsConstructor
public class ReviewRepositoryImpl implements ReviewRepositoryCustom{

  private final JPAQueryFactory queryFactory;

  @Override
  public Page<ReviewWithWriterDto> searchByRestaurantId(String restaurantId, Pageable pageable, boolean onlyImage, String sortType) {
    QReview review = QReview.review;
    QUser user = QUser.user;
    QTitle title = QTitle.title;

    // 리뷰 기본 정보 조회
    List<ReviewWithWriterDto> content = queryFactory
      .select(new QReviewWithWriterDto(
        review.id,
        review.content,
        review.rating,
        review.type,
        review.createdAt,
        user.id,
        user.nickName,
        user.name,
        user.profileImage
      ))
      .from(review)
      .join(user).on(review.userId.eq(user.id))
      .leftJoin(title).on(title.eq(user.title))
      .where(
        review.restaurantId.eq(restaurantId)
          .and(onlyImage ? review.type.eq("image") : null)
      )
      .offset(pageable.getOffset())
      .limit(pageable.getPageSize())
      .orderBy(getOrderSpecifier(sortType))
      .fetch();

    // 리뷰 ID 목록 추출
    List<String> reviewIds = content.stream()
      .map(ReviewWithWriterDto::getReviewId)
      .toList();

    // 이미지 맵
    QReviewImage image = QReviewImage.reviewImage;

    Map<String, List<String>> imageMap = queryFactory
      .select(image.review.id, image.imageName)
      .from(image)
      .where(image.review.id.in(reviewIds))
      .fetch()
      .stream()
      .collect(Collectors.groupingBy(
        tuple -> tuple.get(0, String.class),
        Collectors.mapping(t -> t.get(1, String.class), Collectors.toList())
      ));

    // 메뉴 맵
    QReviewMenu menu = QReviewMenu.reviewMenu;

    Map<String, List<String>> menuMap = queryFactory
      .select(menu.review.id, menu.menuName)
      .from(menu)
      .where(menu.review.id.in(reviewIds))
      .fetch()
      .stream()
      .collect(Collectors.groupingBy(
        tuple -> tuple.get(0, String.class),
        Collectors.mapping(t -> t.get(1, String.class), Collectors.toList())
      ));

    // DTO에 이미지와 메뉴 리스트 주입
    for (ReviewWithWriterDto dto : content) {
      dto.setImageNames(imageMap.getOrDefault(dto.getReviewId(), List.of()));
      dto.setMenuNames(menuMap.getOrDefault(dto.getReviewId(), List.of()));
    }

    // 전체 개수
    long total = queryFactory
      .select(review.count())
      .from(review)
      .where(review.restaurantId.eq(restaurantId))
      .fetchOne();

    return new PageImpl<>(content, pageable, total);
  }

  private OrderSpecifier<?> getOrderSpecifier(String sortType) {
    QReview review = QReview.review;
    return switch (sortType) {
      case "latest" -> new OrderSpecifier<>(Order.DESC, review.createdAt);
      case "earliest" -> new OrderSpecifier<>(Order.ASC, review.createdAt);
      case "highRating" -> new OrderSpecifier<>(Order.DESC, review.rating);
      case "lowRating" -> new OrderSpecifier<>(Order.ASC, review.rating);
      default -> throw new CustomException(ErrorCode.INVALID_SORT_TYPE);
    };
  }
}
