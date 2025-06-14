package com.gachi_janchi.service;

import com.gachi_janchi.dto.GetIngredientByRestaurantIdResponse;
import com.gachi_janchi.dto.GetRestaurantMenuResponse;
import com.gachi_janchi.dto.RestaurantDetailInfo;
import com.gachi_janchi.dto.RestaurantDetailScreenResponse;
import com.gachi_janchi.dto.RestaurantWithIngredientAndReviewCountDto;
import com.gachi_janchi.dto.RestaurantsByBoundsResponse;
import com.gachi_janchi.dto.RestaurantsByKeywordResponse;
import com.gachi_janchi.dto.ReviewCountAndAvg;
import com.gachi_janchi.entity.Ingredient;
import com.gachi_janchi.entity.Restaurant;
import com.gachi_janchi.entity.RestaurantIngredient;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.gachi_janchi.repository.RestaurantIngredientRepository;
import com.gachi_janchi.repository.RestaurantRepository;
import com.gachi_janchi.repository.ReviewRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class RestaurantService {
  @Autowired
  private RestaurantRepository restaurantRepository;

  @Autowired
  private RestaurantIngredientRepository restaurantIngredientRepository;

  @Autowired
  private IngredientService ingredientService;

  @Autowired
  private ReviewRepository reviewRepository;

  // dong을 기준으로 Restaurant 찾기
  // public RestaurantsByDongResponse findRestaurantsByDong(String dong) {
  //   List<Restaurant> restaurants = restaurantRepository.findByAddress_Dong(dong);
  //   return new RestaurantsByDongResponse(restaurants);
  // }

  // 지도에 보이는 영역을 기준으로 Restaurant 찾기
  public RestaurantsByBoundsResponse findRestaurantsInBounds(double latMin, double latMax, double lonMin, double lonMax) {
    List<Restaurant> restaurants = restaurantRepository.findByLocationLatitudeBetweenAndLocationLongitudeBetween(latMin, latMax, lonMin, lonMax);

    List<String> restaurantIds = restaurants.stream()
      .map(Restaurant::getId)
      .toList();

    // 리뷰, 평균값 한 번에 조회
    List<ReviewCountAndAvg> reviewStats = reviewRepository.findReviewStatsByRestaurantIds(restaurantIds);
    Map<String, ReviewCountAndAvg> reviewStatMap = reviewStats.stream()
      .collect(Collectors.toMap(ReviewCountAndAvg::getRestaurantId, Function.identity()));

    // 재료 한 번에 조회
    List<RestaurantIngredient> restaurantIngredients = restaurantIngredientRepository.findByRestaurantIdIn(restaurantIds);
    Map<String, Ingredient> ingredientMap = restaurantIngredients.stream()
      .collect(Collectors.toMap(RestaurantIngredient::getRestaurantId, RestaurantIngredient::getIngredient));

    // DTO 생성
    List<RestaurantWithIngredientAndReviewCountDto> restaurantWithIngredientAndReviewCountDtos = restaurants.stream()
      .map(restaurant -> {
        ReviewCountAndAvg stats = reviewStatMap.getOrDefault(
          restaurant.getId(), new ReviewCountAndAvg(restaurant.getId(), 0L, 0.0));
        Ingredient ingredient = ingredientMap.get(restaurant.getId());
        return RestaurantWithIngredientAndReviewCountDto.from(restaurant, ingredient, stats);
      })
      .toList();

    return new RestaurantsByBoundsResponse(restaurantWithIngredientAndReviewCountDtos);
  }

  // 검색어로 Restaurant 찾기
  public RestaurantsByKeywordResponse findRestaurantsByKeyword(String keyword) {
    List<Restaurant> restaurants = restaurantRepository.searchRestaurants(keyword);

    List<RestaurantWithIngredientAndReviewCountDto> restaurantWithIngredientDtos = makeRestaurantWithIngredientDtos(restaurants);

    return new RestaurantsByKeywordResponse(restaurantWithIngredientDtos);
  }

  // 음식점 id로 Restaurant 찾기
  public RestaurantDetailScreenResponse findRestaurantByRestaurantId(String restaurantId) {
    Restaurant restaurant = restaurantRepository.findById(restaurantId)
      // .orElseThrow(() -> new IllegalArgumentException("음식점을 찾을 수 없습니다. - " + restaurantId));
      .orElseThrow(() -> new CustomException(ErrorCode.RESTAURANT_NOT_FOUND));

    ReviewCountAndAvg reviewCountAndAvg = new ReviewCountAndAvg(
      restaurantId,
      reviewRepository.countByRestaurantId(restaurant.getId()),
      reviewRepository.findAverageRatingByRestaurantId(restaurant.getId())
    );

    RestaurantDetailInfo restaurantDetailInfo = RestaurantDetailInfo.from(restaurant, reviewCountAndAvg);

    return new RestaurantDetailScreenResponse(restaurantDetailInfo);

  }

  // Restaurant 삭세 / 동시에 restaurantIngredient에서도 삭제
  @Transactional
  public void deleteRestaurant(String restaurantId) {
    // MySQL의 restaurant_ingredients에서 먼저 삭제
    restaurantIngredientRepository.deleteByRestaurantId(restaurantId);

    // MongoDB에서 음식점 삭제
    restaurantRepository.deleteById(restaurantId);

    System.out.println("음식점 삭제 완료: " + restaurantId);
  }

  // 음식점 id로 restaurant 찾기
  public GetIngredientByRestaurantIdResponse findIngredientByRestaurantId(String restaurantId) {

    // 찾은 음식점에 대한 재료 찾기
    Ingredient ingredient = ingredientService.findIngredientByRestaurantId(restaurantId);

    return new GetIngredientByRestaurantIdResponse(ingredient.getId());
  }

  // List<Restaurant>로 List<RestaurantWithIngredientDto> 만들어주는 함수
  public List<RestaurantWithIngredientAndReviewCountDto> makeRestaurantWithIngredientDtos(List<Restaurant> restaurants) {
    return restaurants.stream()
            .map(restaurant -> {
              ReviewCountAndAvg reviewCountAndAvg = new ReviewCountAndAvg(
                restaurant.getId(),
                reviewRepository.countByRestaurantId(restaurant.getId()),
                reviewRepository.findAverageRatingByRestaurantId(restaurant.getId())
              );
              System.out.println("reviewCountAndAvg: " + reviewCountAndAvg);
              Ingredient ingredient = ingredientService.findIngredientByRestaurantId(restaurant.getId());
              return RestaurantWithIngredientAndReviewCountDto.from(restaurant, ingredient, reviewCountAndAvg);
            })
            .collect(Collectors.toList());
  }

  // 음식점 아이디로 메뉴 반환해주는 함수
  public GetRestaurantMenuResponse getRestaurantMenuByRestaurantId(String restaurantId) {
    Restaurant restaurant = restaurantRepository.findById(restaurantId)
      // .orElseThrow(() -> new IllegalArgumentException("음식점을 찾을 수 없습니다. - " + restaurantId));
      .orElseThrow(() -> new CustomException(ErrorCode.RESTAURANT_NOT_FOUND));
    return new GetRestaurantMenuResponse(restaurant.getMenu());
  }
}
