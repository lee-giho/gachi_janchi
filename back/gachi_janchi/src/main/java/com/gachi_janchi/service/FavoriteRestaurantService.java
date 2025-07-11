package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.FavoriteRestaurant;
import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.gachi_janchi.repository.FavoriteRestaurantRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import com.gachi_janchi.repository.ReviewRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteRestaurantService {
  private final FavoriteRestaurantRepository favoriteRestaurantRepository;
  private final RestaurantRepository restaurantRepository;
  private final JwtProvider jwtProvider;
  private final UserRepository userRepository;
  private final IngredientService ingredientService;
  private final ReviewRepository reviewRepository;

  @Transactional
  public AddFavoriteRestaurantResponse addFavoriteRestaurant(AddFavoriteRestaurantRequest addFavoriteRestaurantRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String restaurantId = addFavoriteRestaurantRequest.getRestaurantId();
    String userId = jwtProvider.getUserId(accessToken);

    // 음식점이 존재하는지 확인
    Restaurant restaurant = restaurantRepository.findById(restaurantId)
      // .orElseThrow(() -> new IllegalArgumentException("해당 음식점이 존재하지 않습니다. - " + restaurantId));
      .orElseThrow(() -> new CustomException(ErrorCode.RESTAURANT_NOT_FOUND));

    // 이미 즐겨찾기 되어있는지 확인
    if (favoriteRestaurantRepository.findByUserIdAndRestaurantId(userId, restaurantId).isPresent()) {
      // throw new IllegalArgumentException("이미 즐겨찾기한 음식점입니다.");
      throw new CustomException(ErrorCode.FAVORITE_RESTAURANT_ALREADY_EXIST);
    }

    FavoriteRestaurant favoriteRestaurant = new FavoriteRestaurant(
            UUID.randomUUID().toString(),
            userId,
            restaurantId
    );
    favoriteRestaurantRepository.save(favoriteRestaurant);
    return new AddFavoriteRestaurantResponse("즐겨찾기 추가 완료");
  }


  // 특정 사용자의 즐겨찾기 목록 조회
  public GetFavoriteRestaurantsResponse getUserFavorites(String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(accessToken);

    // 즐겨찾기 음식점 아이디 가져오기
    List<String> favoriteRestaurantIds = favoriteRestaurantRepository.findByUserId(userId)
            .stream()
            .map(favoriteRestaurant -> favoriteRestaurant.getRestaurantId())
            .collect(Collectors.toList());

    // 즐겨찾기 음식점 아이디로 List<Restaurant> 만들기
    List<Restaurant> favoriteRestaurants = restaurantRepository.findAllById(favoriteRestaurantIds);

    List<RestaurantWithIngredientAndReviewCountDto> restaurantWithIngredientDtos = favoriteRestaurants.stream()
            .map(restaurant -> {
              ReviewCountAndAvg reviewCountAndAvg = new ReviewCountAndAvg(
                restaurant.getId(),
                reviewRepository.countByRestaurantId(restaurant.getId()),
                reviewRepository.findAverageRatingByRestaurantId(restaurant.getId())
              );

              Ingredient ingredient = ingredientService.findIngredientByRestaurantId(restaurant.getId());
              return RestaurantWithIngredientAndReviewCountDto.from(restaurant, ingredient, reviewCountAndAvg);
            })
            .collect(Collectors.toList());

    return new GetFavoriteRestaurantsResponse(restaurantWithIngredientDtos);
  }

  // 즐겨찾기 삭제
  @Transactional
  public DeleteFavoriteRestaurantResponse deleteFavoriteRestaurant(DeleteFavoriteRestaurantRequest deleteFavoriteRestaurantRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String id = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(id)
      // .orElseThrow(() -> new IllegalArgumentException("User not found"));
      .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    String restaurantId = deleteFavoriteRestaurantRequest.getRestaurantId();
    String userId = user.getId();

    if (favoriteRestaurantRepository.findByUserIdAndRestaurantId(userId, restaurantId).isEmpty()) {
      // throw new IllegalArgumentException("해당 즐겨찾기가 존재하지 않습니다.");
      throw new CustomException(ErrorCode.FAVORITE_RESTAURANT_NOT_FOUND);
    }
    favoriteRestaurantRepository.deleteByUserIdAndRestaurantId(userId, restaurantId);
    return new DeleteFavoriteRestaurantResponse("즐겨찾기 삭제 완료");
  }

  // 음식점별 즐겨찾기 수 반환
  public GetFavoriteCountResponse getFavoriteCount(String restaurantId) {
    String favoriteCount = favoriteRestaurantRepository.countByRestaurantId(restaurantId).toString();
    return new GetFavoriteCountResponse(favoriteCount);
  }
}