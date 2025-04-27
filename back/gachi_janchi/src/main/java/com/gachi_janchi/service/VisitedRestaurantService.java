package com.gachi_janchi.service;

import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gachi_janchi.dto.AddVisitedRestaurantRequest;
import com.gachi_janchi.dto.AddVisitedRestaurantResponse;
import com.gachi_janchi.dto.VisitedRestaurantDto;
import com.gachi_janchi.dto.VisitedRestaurantList;
import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.entity.VisitedRestaurant;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.gachi_janchi.repository.IngredientRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import com.gachi_janchi.repository.ReviewRepository;
import com.gachi_janchi.repository.VisitedRestaurantRepository;
import com.gachi_janchi.util.JwtProvider;

import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VisitedRestaurantService {
  private final VisitedRestaurantRepository visitedRestaurantRepository;
  private final RestaurantRepository restaurantRepository;
  private final IngredientRepository ingredientRepository;
  private final ReviewRepository reviewRepository;
  private final JwtProvider jwtProvider;

  @Transactional
  public AddVisitedRestaurantResponse addVisitedRestaurantResponse(AddVisitedRestaurantRequest addVisitedRestaurantRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String userId = jwtProvider.getUserId(accessToken);
    String restaurantId = addVisitedRestaurantRequest.getRestaurantId();
    Long ingredientId = addVisitedRestaurantRequest.getIngredientId();

    // 음식점이 존재하는지 확인
    Boolean isExistsRestaurant = restaurantRepository.existsById(restaurantId);

    // 재료가 존재하는지 확인
    Boolean isExistsIngredient = ingredientRepository.existsById(ingredientId);

    if (isExistsRestaurant) {
      if (isExistsIngredient) {
        VisitedRestaurant visitedRestaurant = new VisitedRestaurant(
          UUID.randomUUID().toString(),
          userId,
          restaurantId,
          ingredientId
        );
        visitedRestaurantRepository.save(visitedRestaurant);
        return new AddVisitedRestaurantResponse("방문한 음식점 추가 완료");
      } else {
        System.out.println("재료가 존재하지 않습니다. - " + ingredientId);
        return new AddVisitedRestaurantResponse("재료가 존재하지 않습니다.");
      }
    } else {
      System.out.println("음식점이 존재하지 않습니다. - " + restaurantId);
      return new AddVisitedRestaurantResponse("음식점이 존재하지 않습니다.");
    }
  }

  public VisitedRestaurantList getVisitedRestaurants(String token, String sortType) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(accessToken);

    // 방문한 음식점 리스트 가져오기
    List<VisitedRestaurant> visitedRestaurants = new ArrayList<>();

    if (sortType.equals("latest")) {
      visitedRestaurants = visitedRestaurantRepository.findByUserIdOrderByVisitedAtDesc(userId);
    }

    List<VisitedRestaurantDto> visitedRestaurantDtos = visitedRestaurants.stream()
      .map(visitedRestaurant -> {
        Restaurant restaurant = restaurantRepository.findById(visitedRestaurant.getRestaurantId())
          // .orElseThrow(() -> new IllegalArgumentException("해당 음식점이 존재하지 않습니다. - " + visitedRestaurant.getRestaurantId()));
          .orElseThrow(() -> new CustomException(ErrorCode.RESTAURANT_NOT_FOUND));
        Ingredient ingredient = ingredientRepository.findById(visitedRestaurant.getIngredientId())
          // .orElseThrow(() -> new IllegalArgumentException("해당 재료가 존재하지 않습니다. - " + visitedRestaurant.getIngredientId()));
          .orElseThrow(() -> new CustomException(ErrorCode.INGREDIENT_NOT_FOUND));
        // 방문한 음심점에 리뷰를 작성했는지 여부 확인
        Boolean isReviewWrite = reviewRepository.existsByVisitedId(visitedRestaurant.getId());
        System.out.println("isReviewWrite: " + isReviewWrite);
        return VisitedRestaurantDto.builder()
          .restaurant(restaurant)
          .visitedId(visitedRestaurant.getId())
          .visitedAt(visitedRestaurant.getVisitedAt())
          .ingredientName(ingredient.getName())
          .isReviewWrite(isReviewWrite)
          .build();
      })
      .collect(Collectors.toList());

    return new VisitedRestaurantList(visitedRestaurantDtos);
  }
}
