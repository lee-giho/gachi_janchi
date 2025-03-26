package com.gachi_janchi.service;

import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.gachi_janchi.dto.AddVisitedRestaurantRequest;
import com.gachi_janchi.dto.AddVisitedRestaurantResponse;
import com.gachi_janchi.entity.VisitedRestaurant;
import com.gachi_janchi.repository.IngredientRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import com.gachi_janchi.repository.VisitedRestaurantRepository;
import com.gachi_janchi.util.JwtProvider;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VisitedRestaurantService {
  private final VisitedRestaurantRepository visitedRestaurantRepository;
  private final RestaurantRepository restaurantRepository;
  private final IngredientRepository ingredientRepository;
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
}
